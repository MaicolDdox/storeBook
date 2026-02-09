<template>
  <button v-bind="$attrs" :type="type" :disabled="disabled" :class="buttonClasses">
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
    'inline-flex items-center justify-center rounded-xl border-2 border-transparent border-brightBlue px-5 py-2.5 text-sm font-bold text-brightBlue transition hover:bg-lightBlue'
  const variants = {
    primary: ['border-transparent bg-[#0097c9] text-white'].join(' '),
    secondary: [
      'border-brightBlue bg-brightBlue/15 text-slate-800',
      'hover:bg-brightBlue hover:text-gray-500 focus-visible:outline-brightBlue',
    ].join(' '),
    danger: [
      'border-transparent bg-rose-600 text-white',
      'hover:bg-rose-700 focus-visible:outline-rose-600',
    ].join(' '),
  }
  return [base, variants[props.variant]].filter(Boolean).join(' ')
})
</script>
