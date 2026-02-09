<template>
  <div class="space-y-4" v-if="ordersStore.order">
    <BaseCard>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-2xl font-extrabold text-slate-800">Order #{{ ordersStore.order.id }}</h1>
          <p class="text-sm text-slate-500">
            Placed {{ formatDate(ordersStore.order.created_at) }}
          </p>
        </div>
        <BaseBadge :tone="statusTone(ordersStore.order.status)">
          {{ ordersStore.order.status }}
        </BaseBadge>
      </div>
    </BaseCard>

    <BaseCard>
      <h2 class="mb-3 text-lg font-bold text-slate-800">Items</h2>
      <div class="space-y-2 text-sm text-slate-700">
        <div
          v-for="item in ordersStore.order.items"
          :key="item.id"
          class="flex justify-between rounded-lg border border-sky-100 px-3 py-2"
        >
          <span>{{ item.title_snapshot }} x{{ item.quantity }}</span>
          <span>${{ (item.total_price_cents / 100).toFixed(2) }}</span>
        </div>
      </div>
    </BaseCard>

    <BaseCard>
      <h2 class="mb-2 text-lg font-bold text-slate-800">Shipping address</h2>
      <p class="text-sm text-slate-600">
        {{ ordersStore.order.address?.recipient_name }} - {{ ordersStore.order.address?.line1 }},
        {{ ordersStore.order.address?.city }}, {{ ordersStore.order.address?.postal_code }}
      </p>
      <p class="mt-4 text-lg font-extrabold text-brightBlue">
        Total: ${{ (ordersStore.order.total_cents / 100).toFixed(2) }}
      </p>
    </BaseCard>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRoute } from 'vue-router'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseBadge from '@/components/base/BaseBadge.vue'
import { useOrdersStore } from '@/stores/orders'

const route = useRoute()
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
  await ordersStore.fetchOrder(route.params.id)
})
</script>
