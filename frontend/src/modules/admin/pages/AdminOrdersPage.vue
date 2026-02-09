<template>
  <div class="space-y-4">
    <BaseCard>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-2xl font-extrabold text-slate-800">Manage Orders</h1>
          <p class="text-sm text-slate-500">Monitor orders and update fulfillment status.</p>
        </div>
        <label class="text-sm">
          Status
          <select
            v-model="statusFilter"
            class="ml-2 rounded-lg border border-sky-100 px-2 py-1"
            @change="fetchOrders"
          >
            <option value="">All</option>
            <option v-for="status in statuses" :key="status" :value="status">{{ status }}</option>
          </select>
        </label>
      </div>
    </BaseCard>

    <BaseTable>
      <template #head>
        <th class="px-4 py-3 font-semibold">Order</th>
        <th class="px-4 py-3 font-semibold">User</th>
        <th class="px-4 py-3 font-semibold">Total</th>
        <th class="px-4 py-3 font-semibold">Status</th>
      </template>

      <template #body>
        <tr v-for="order in orders" :key="order.id" class="border-t border-sky-50">
          <td class="px-4 py-3 text-sm text-slate-700">#{{ order.id }}</td>
          <td class="px-4 py-3 text-sm text-slate-700">{{ order.user?.email || 'N/A' }}</td>
          <td class="px-4 py-3 text-sm text-slate-700">
            ${{ (order.total_cents / 100).toFixed(2) }}
          </td>
          <td class="px-4 py-3">
            <select
              :value="order.status"
              class="rounded-lg border border-sky-100 px-2 py-1 text-sm"
              @change="updateStatus(order.id, $event.target.value)"
            >
              <option v-for="status in statuses" :key="status" :value="status">{{ status }}</option>
            </select>
          </td>
        </tr>
      </template>
    </BaseTable>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseTable from '@/components/base/BaseTable.vue'
import { http } from '@/services/http'
import { useUiStore } from '@/stores/ui'

const uiStore = useUiStore()
const orders = ref([])
const statusFilter = ref('')
const statuses = ['pending', 'paid', 'processing', 'shipped', 'completed', 'cancelled']

async function fetchOrders() {
  const { data } = await http.get('/admin/orders', {
    params: { per_page: 50, status: statusFilter.value || undefined },
  })
  orders.value = data.data
}

async function updateStatus(orderId, status) {
  try {
    await http.patch(`/admin/orders/${orderId}/status`, { status })
    uiStore.pushToast('Order status updated.', 'success')
    await fetchOrders()
  } catch {
    uiStore.pushToast('Unable to update order status.', 'error')
  }
}

onMounted(fetchOrders)
</script>
