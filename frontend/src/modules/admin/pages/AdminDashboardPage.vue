<template>
  <div class="space-y-6">
    <div class="flex flex-wrap items-center justify-between gap-4">
      <h1 class="text-2xl font-extrabold text-slate-800">Dashboard</h1>
      <select
        v-model="range"
        class="rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm font-medium text-slate-700 outline-none focus:border-brightBlue"
        @change="loadCharts"
      >
        <option value="7d">Last 7 days</option>
        <option value="30d">Last 30 days</option>
        <option value="90d">Last 90 days</option>
      </select>
    </div>

    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-5">
      <BaseCard v-for="metric in metrics" :key="metric.key">
        <p class="text-xs font-semibold uppercase tracking-wide text-slate-500">
          {{ metric.label }}
        </p>
        <p class="mt-2 text-3xl font-extrabold text-slate-800">
          {{ metric.value }}
        </p>
      </BaseCard>
    </div>

    <div class="grid gap-6 lg:grid-cols-2">
      <BaseCard>
        <h2 class="mb-4 text-lg font-bold text-slate-800">Orders Over Time</h2>
        <div class="h-64">
          <v-chart v-if="ordersChartOption" :option="ordersChartOption" autoresize class="h-full w-full" />
        </div>
      </BaseCard>
      <BaseCard>
        <h2 class="mb-4 text-lg font-bold text-slate-800">Order Status Distribution</h2>
        <div class="h-64">
          <v-chart v-if="statusChartOption" :option="statusChartOption" autoresize class="h-full w-full" />
        </div>
      </BaseCard>
    </div>

    <div class="grid gap-6 lg:grid-cols-2">
      <BaseCard>
        <h2 class="mb-4 text-lg font-bold text-slate-800">Top Categories</h2>
        <div class="h-64">
          <v-chart v-if="categoriesChartOption" :option="categoriesChartOption" autoresize class="h-full w-full" />
        </div>
      </BaseCard>
      <BaseCard>
        <h2 class="mb-4 text-lg font-bold text-slate-800">Low Stock Books</h2>
        <ul v-if="lowStock.length > 0" class="space-y-2">
          <li
            v-for="book in lowStock"
            :key="book.id"
            class="flex items-center justify-between rounded-lg bg-lightBlue/50 px-3 py-2 text-sm"
          >
            <span class="font-medium text-slate-700">{{ book.title }}</span>
            <span class="rounded bg-rose-100 px-2 py-0.5 font-semibold text-rose-700">
              {{ book.stock_quantity }} left
            </span>
          </li>
        </ul>
        <p v-else class="py-4 text-center text-sm text-slate-500">No low stock books.</p>
      </BaseCard>
    </div>

    <BaseCard>
      <h2 class="mb-4 text-lg font-bold text-slate-800">Recent Orders</h2>
      <BaseTable v-if="recentOrders.length > 0">
        <template #head>
          <th class="px-4 py-3 font-semibold">ID</th>
          <th class="px-4 py-3 font-semibold">Customer</th>
          <th class="px-4 py-3 font-semibold">Total</th>
          <th class="px-4 py-3 font-semibold">Status</th>
          <th class="px-4 py-3 font-semibold">Date</th>
        </template>
        <template #body>
          <tr
            v-for="order in recentOrders"
            :key="order.id"
            class="border-t border-sky-50 transition hover:bg-lightBlue/30"
          >
            <td class="px-4 py-3 text-sm text-slate-700">#{{ order.id }}</td>
            <td class="px-4 py-3 text-sm text-slate-700">{{ order.user?.email ?? '-' }}</td>
            <td class="px-4 py-3 text-sm text-slate-700">
              ${{ (order.total_cents / 100).toFixed(2) }}
            </td>
            <td class="px-4 py-3 text-sm text-slate-700">{{ order.status }}</td>
            <td class="px-4 py-3 text-sm text-slate-600">
              {{ order.created_at ? new Date(order.created_at).toLocaleDateString() : '-' }}
            </td>
          </tr>
        </template>
      </BaseTable>
      <p v-else class="py-4 text-center text-sm text-slate-500">No orders yet.</p>
    </BaseCard>
  </div>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { use } from 'echarts/core'
import { BarChart, LineChart, PieChart } from 'echarts/charts'
import {
  GridComponent,
  TooltipComponent,
  TitleComponent,
  LegendComponent,
} from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import VChart from 'vue-echarts'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseTable from '@/components/base/BaseTable.vue'
import { adminApi } from '@/services/admin.api'

use([BarChart, LineChart, PieChart, GridComponent, TooltipComponent, TitleComponent, LegendComponent, CanvasRenderer])

const range = ref('30d')
const overview = ref({
  books_count: 0,
  categories_count: 0,
  orders_count: 0,
  pending_orders_count: 0,
  paid_revenue_cents: 0,
})
const ordersData = ref({ labels: [], values: [] })
const topCategories = ref([])
const statusDistribution = ref([])
const recentOrders = ref([])
const lowStock = ref([])

const metrics = computed(() => [
  { key: 'books', label: 'Books', value: overview.value.books_count },
  { key: 'categories', label: 'Categories', value: overview.value.categories_count },
  { key: 'orders', label: 'Orders', value: overview.value.orders_count },
  { key: 'pending', label: 'Pending orders', value: overview.value.pending_orders_count },
  {
    key: 'revenue',
    label: 'Paid revenue',
    value: `$${(overview.value.paid_revenue_cents / 100).toFixed(2)}`,
  },
])

const ordersChartOption = computed(() => {
  if (!ordersData.value.labels?.length) return null
  return {
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '5%', containLabel: true },
    xAxis: {
      type: 'category',
      data: ordersData.value.labels.map((d) => d.slice(5)),
      axisLabel: { color: '#475569' },
    },
    yAxis: {
      type: 'value',
      axisLabel: { color: '#475569' },
      splitLine: { lineStyle: { color: '#e2e8f0' } },
    },
    series: [
      {
        type: 'line',
        data: ordersData.value.values,
        smooth: true,
        lineStyle: { color: '#00ABE4' },
        itemStyle: { color: '#00ABE4' },
        areaStyle: { color: 'rgba(0, 171, 228, 0.2)' },
      },
    ],
  }
})

const statusChartOption = computed(() => {
  if (!statusDistribution.value.length) return null
  return {
    tooltip: { trigger: 'item' },
    legend: { bottom: 0, textStyle: { color: '#475569' } },
    series: [
      {
        type: 'pie',
        radius: ['40%', '70%'],
        center: ['50%', '45%'],
        data: statusDistribution.value.map((item, i) => ({
          value: item.value,
          name: item.name,
          itemStyle: {
            color: ['#00ABE4', '#E9F1FA', '#0f2940', '#64748b', '#94a3b8'][i % 5],
          },
        })),
        label: { color: '#475569' },
      },
    ],
  }
})

const categoriesChartOption = computed(() => {
  if (!topCategories.value.length) return null
  return {
    tooltip: { trigger: 'axis' },
    grid: { left: '3%', right: '4%', bottom: '3%', top: '5%', containLabel: true },
    xAxis: {
      type: 'category',
      data: topCategories.value.map((c) => c.name),
      axisLabel: { color: '#475569', rotate: 30 },
    },
    yAxis: {
      type: 'value',
      axisLabel: { color: '#475569' },
      splitLine: { lineStyle: { color: '#e2e8f0' } },
    },
    series: [
      {
        type: 'bar',
        data: topCategories.value.map((c) => c.value),
        itemStyle: { color: '#00ABE4' },
      },
    ],
  }
})

async function loadOverview() {
  const { data } = await adminApi.getDashboard()
  overview.value = data.data
}

async function loadCharts() {
  const [ordersRes, categoriesRes, statusRes] = await Promise.all([
    adminApi.getOrdersOverTime(range.value),
    adminApi.getTopCategories(range.value),
    adminApi.getOrderStatusDistribution(range.value),
  ])
  ordersData.value = {
    labels: ordersRes.data.data.labels,
    values: ordersRes.data.data.values,
  }
  topCategories.value = categoriesRes.data.data.items
  statusDistribution.value = statusRes.data.data.items
}

async function loadRecentAndLowStock() {
  const [recentRes, lowRes] = await Promise.all([
    adminApi.getRecentOrders(),
    adminApi.getLowStock(),
  ])
  recentOrders.value = recentRes.data.data
  lowStock.value = lowRes.data.data
}

async function load() {
  await Promise.all([loadOverview(), loadCharts(), loadRecentAndLowStock()])
}

onMounted(load)
</script>
