<template>
  <BaseCard>
    <div class="py-8 text-center">
      <ExclamationTriangleIcon class="mx-auto h-12 w-12 text-rose-400" />
      <p class="mt-3 text-sm font-medium text-slate-600">
        {{ message || 'Unable to load the catalog. Please try again.' }}
      </p>
      <AppButton v-if="retryable" variant="secondary" class="mt-4" @click="$emit('retry')">
        Retry
      </AppButton>
    </div>
  </BaseCard>
</template>

<script setup>
import { ExclamationTriangleIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'
import AppButton from '@/components/ui/AppButton.vue'

defineProps({
  message: {
    type: String,
    default: '',
  },
  retryable: {
    type: Boolean,
    default: true,
  },
})

defineEmits(['retry'])
</script>
