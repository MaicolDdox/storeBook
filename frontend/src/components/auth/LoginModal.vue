<template>
  <BaseModal :open="uiStore.loginModalOpen" title="Sign In" @close="handleClose">
    <div class="space-y-4">
      <p class="text-sm text-slate-600">
        Sign in to add items to your cart and complete your purchase.
      </p>
      <LoginForm @success="handleSuccess" />
      <p class="text-center text-sm text-slate-600">
        New here?
        <router-link to="/register" class="font-semibold text-brightBlue" @click="handleClose">
          Create account
        </router-link>
      </p>
    </div>
  </BaseModal>
</template>

<script setup>
import BaseModal from '@/components/base/BaseModal.vue'
import LoginForm from '@/components/auth/LoginForm.vue'
import { useUiStore } from '@/stores/ui'

const uiStore = useUiStore()

async function handleSuccess() {
  await uiStore.runPendingAuthAction()
  uiStore.setLoginModalOpen(false)
}

function handleClose() {
  uiStore.setLoginModalOpen(false)
  uiStore.clearPendingAuthAction()
}
</script>
