<template>
  <button
    :type="type"
    :disabled="disabled"
    :class="[
      'inline-flex items-center justify-center gap-2 rounded-xl px-4 py-2 text-sm font-semibold transition',
      disabled ? 'cursor-not-allowed opacity-60' : 'hover:-translate-y-0.5',
      variantClasses,
    ]"
  >
    <slot />
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  type: {
    type: String,
    default: 'button',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  variant: {
    type: String,
    default: 'primary',
  },
})

const variantClasses = computed(() => {
  if (props.variant === 'secondary') {
    return 'bg-white text-brightBlue border border-brightBlue'
  }

  if (props.variant === 'danger') {
    return 'bg-red-500 text-white'
  }

  return 'bg-brightBlue text-white'
})
</script>
