<template>
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
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import BaseCard from '@/components/base/BaseCard.vue'
import { http } from '@/services/http'

const payload = ref({
  books_count: 0,
  categories_count: 0,
  orders_count: 0,
  pending_orders_count: 0,
  paid_revenue_cents: 0,
})

const metrics = computed(() => [
  { key: 'books', label: 'Books', value: payload.value.books_count },
  { key: 'categories', label: 'Categories', value: payload.value.categories_count },
  { key: 'orders', label: 'Orders', value: payload.value.orders_count },
  { key: 'pending', label: 'Pending orders', value: payload.value.pending_orders_count },
  {
    key: 'revenue',
    label: 'Paid revenue',
    value: `$${(payload.value.paid_revenue_cents / 100).toFixed(2)}`,
  },
])

onMounted(async () => {
  const { data } = await http.get('/admin/dashboard')
  payload.value = data.data
})
</script>
