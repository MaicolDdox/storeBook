<template>
  <button
    type="button"
    class="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-amber-200/50"
    :aria-label="ariaLabel"
    :disabled="disabled"
    @click="$emit('click')"
  >
    <PencilSquareIcon class="h-4 w-4 text-slate-500" />
  </button>
</template>

<script setup>
import { PencilSquareIcon } from '@heroicons/vue/24/solid'

defineProps({
  ariaLabel: {
    type: String,
    default: 'Edit',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['click'])
</script>
