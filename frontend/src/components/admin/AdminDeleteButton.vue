<template>
  <button
    type="button"
    class="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-red-200/50 disabled:cursor-not-allowed disabled:opacity-60"
    :aria-label="ariaLabel"
    :disabled="disabled"
    @click="$emit('click')"
  >
    <TrashIcon class="h-4 w-4 text-slate-500" />
  </button>
</template>

<script setup>
import { TrashIcon } from '@heroicons/vue/24/solid'

defineProps({
  ariaLabel: {
    type: String,
    default: 'Delete',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['click'])
</script>
