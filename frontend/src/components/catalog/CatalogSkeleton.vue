<template>
  <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
    <div v-for="i in count" :key="i" class="overflow-hidden rounded-2xl bg-white p-4 shadow-panel">
      <div class="mb-3 h-44 animate-pulse rounded-xl bg-slate-200" />
      <div class="mb-2 h-5 w-3/4 animate-pulse rounded bg-slate-200" />
      <div class="mb-2 h-4 w-1/3 animate-pulse rounded bg-slate-200" />
      <div class="mb-4 h-4 w-full animate-pulse rounded bg-slate-200" />
      <div class="flex justify-between">
        <div class="h-6 w-20 animate-pulse rounded bg-slate-200" />
        <div class="h-8 w-24 animate-pulse rounded bg-slate-200" />
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  count: {
    type: Number,
    default: 6,
  },
})
</script>
