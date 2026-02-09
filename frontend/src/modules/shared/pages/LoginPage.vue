<template>
  <BaseCard>
    <div class="mb-6 space-y-1 text-center">
      <h1 class="text-2xl font-extrabold text-slate-800">Sign In</h1>
      <p class="text-sm text-slate-500">Access your account to continue shopping.</p>
    </div>

    <LoginForm @success="handleSuccess" />

    <p class="mt-5 text-center text-sm text-slate-600">
      New here?
      <router-link to="/register" class="font-semibold text-brightBlue">Create account</router-link>
    </p>
  </BaseCard>
</template>

<script setup>
import { useRouter } from 'vue-router'
import BaseCard from '@/components/base/BaseCard.vue'
import LoginForm from '@/components/auth/LoginForm.vue'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const authStore = useAuthStore()
const uiStore = useUiStore()
const router = useRouter()

async function handleSuccess() {
  uiStore.pushToast('Login successful.', 'success')
  const returnUrl = router.currentRoute.value.query.returnUrl
  if (returnUrl && typeof returnUrl === 'string' && !returnUrl.startsWith('/login')) {
    await router.push(returnUrl)
  } else {
    await router.push(authStore.isAdmin ? '/admin/dashboard' : '/')
  }
}
</script>
