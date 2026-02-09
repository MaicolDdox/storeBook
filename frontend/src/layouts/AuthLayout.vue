<template>
  <div class="min-h-screen bg-lightBlue">
    <div class="mx-auto flex min-h-screen w-full max-w-7xl items-center justify-center p-4">
      <div class="w-full max-w-md">
        <router-view />
      </div>
    </div>

    <ToastStack />
    <GlobalLoader />
  </div>
</template>

<script setup>
import ToastStack from '@/components/feedback/ToastStack.vue'
import GlobalLoader from '@/components/feedback/GlobalLoader.vue'
</script>
