<template>
  <button
    v-bind="$attrs"
    :type="type"
    :disabled="disabled"
    :class="buttonClasses"
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
    validator: (v) => ['primary', 'secondary', 'danger'].includes(v),
  },
})

const buttonClasses = computed(() => {
  const base =
    'inline-flex items-center justify-center gap-2 rounded-xl border px-4 py-2 text-sm font-bold transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-60'
  const variants = {
    primary: [
      'border-transparent bg-brightBlue text-white',
      'hover:bg-[#0097c9] focus-visible:outline-brightBlue',
    ].join(' '),
    secondary: [
      'border-brightBlue bg-white text-brightBlue',
      'hover:bg-lightBlue focus-visible:outline-brightBlue',
    ].join(' '),
    danger: [
      'border-transparent bg-rose-600 text-white',
      'hover:bg-rose-700 focus-visible:outline-rose-600',
    ].join(' '),
  }
  return [base, variants[props.variant]].filter(Boolean).join(' ')
})
</script>
