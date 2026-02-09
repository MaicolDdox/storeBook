<template>
  <Teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-40 flex items-center justify-center bg-slate-900/40 p-4"
      @click.self="$emit('close')"
    >
      <div class="w-full max-w-lg rounded-2xl bg-white p-5 shadow-panel sm:p-6">
        <div class="mb-4 flex items-center justify-between">
          <h3 class="text-lg font-bold text-slate-800">{{ title }}</h3>
          <button
            type="button"
            class="rounded-lg px-3 py-1.5 text-sm font-semibold text-slate-600 transition hover:text-slate-800"
            @click="$emit('close')"
          >
            Close
          </button>
        </div>
        <slot />
      </div>
    </div>
  </Teleport>
</template>

<script setup>
defineProps({
  open: {
    type: Boolean,
    default: false,
  },
  title: {
    type: String,
    default: '',
  },
})

defineEmits(['close'])
</script>
