<template>
  <BaseCard>
    <div class="py-8 text-center">
      <BookOpenIcon class="mx-auto h-12 w-12 text-slate-300" />
      <p class="mt-3 text-sm font-medium text-slate-600">
        {{ message || 'No books found for the selected filters.' }}
      </p>
      <p v-if="showReset" class="mt-1 text-sm text-slate-500">
        Try adjusting your search or filters.
      </p>
    </div>
  </BaseCard>
</template>

<script setup>
import { BookOpenIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'

defineProps({
  message: {
    type: String,
    default: '',
  },
  showReset: {
    type: Boolean,
    default: true,
  },
})
</script>
