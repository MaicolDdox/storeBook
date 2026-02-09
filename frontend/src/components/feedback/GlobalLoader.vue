<template>
  <Transition name="fade">
    <div
      v-if="uiStore.isLoading"
      class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/20"
    >
      <div class="rounded-full border-4 border-lightBlue border-t-brightBlue p-6" />
    </div>
  </Transition>
</template>

<script setup>
import { useUiStore } from '@/stores/ui'

const uiStore = useUiStore()
</script>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
