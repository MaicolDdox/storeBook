<template>
  <span
    :class="['inline-flex items-center rounded-full px-2.5 py-1 text-xs font-semibold', toneClass]"
  >
    <slot />
  </span>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  tone: {
    type: String,
    default: 'neutral',
  },
})

const toneClass = computed(() => {
  if (props.tone === 'success') return 'bg-emerald-100 text-emerald-700'
  if (props.tone === 'warning') return 'bg-amber-100 text-amber-700'
  if (props.tone === 'danger') return 'bg-rose-100 text-rose-700'
  return 'bg-sky-100 text-sky-700'
})
</script>
