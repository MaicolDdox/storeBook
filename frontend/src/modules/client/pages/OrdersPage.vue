<template>
  <div class="space-y-4">
    <BaseCard>
      <h1 class="text-2xl font-extrabold text-slate-800">Order History</h1>
      <p class="text-sm text-slate-500">Track your current and previous purchases.</p>
    </BaseCard>

    <BaseCard v-for="order in ordersStore.orders" :key="order.id">
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <p class="text-sm text-slate-500">Order #{{ order.id }}</p>
          <p class="text-lg font-bold text-slate-800">
            ${{ (order.total_cents / 100).toFixed(2) }}
          </p>
          <p class="text-xs text-slate-500">{{ formatDate(order.created_at) }}</p>
        </div>
        <div class="flex items-center gap-2">
          <BaseBadge :tone="statusTone(order.status)">
            {{ order.status }}
          </BaseBadge>
          <router-link
            :to="`/orders/${order.id}`"
            class="rounded-lg border border-sky-200 px-3 py-1.5 text-xs font-semibold text-slate-700"
          >
            View details
          </router-link>
        </div>
      </div>
    </BaseCard>

    <BaseCard v-if="ordersStore.orders.length === 0">
      <p class="text-sm text-slate-600">No orders yet.</p>
    </BaseCard>

    <BasePagination :pagination="ordersStore.pagination" @change="ordersStore.fetchOrders" />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseBadge from '@/components/base/BaseBadge.vue'
import BasePagination from '@/components/base/BasePagination.vue'
import { useOrdersStore } from '@/stores/orders'

const ordersStore = useOrdersStore()

function formatDate(value) {
  return new Date(value).toLocaleString()
}

function statusTone(status) {
  if (status === 'completed' || status === 'paid') return 'success'
  if (status === 'cancelled') return 'danger'
  if (status === 'pending') return 'warning'
  return 'neutral'
}

onMounted(async () => {
  await ordersStore.fetchOrders()
})
</script>
