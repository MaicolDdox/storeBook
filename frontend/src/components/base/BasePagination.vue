<template>
  <div class="flex flex-wrap items-center justify-between gap-3">
    <p class="text-sm text-slate-600">
      Page {{ pagination.current_page }} of {{ pagination.last_page }}
    </p>
    <div class="flex items-center gap-2">
      <AppButton
        variant="secondary"
        :disabled="pagination.current_page <= 1"
        @click="$emit('change', pagination.current_page - 1)"
      >
        Previous
      </AppButton>
      <AppButton
        variant="secondary"
        :disabled="pagination.current_page >= pagination.last_page"
        @click="$emit('change', pagination.current_page + 1)"
      >
        Next
      </AppButton>
    </div>
  </div>
</template>

<script setup>
import AppButton from '@/components/ui/AppButton.vue'

defineProps({
  pagination: {
    type: Object,
    required: true,
  },
})

defineEmits(['change'])
</script>
