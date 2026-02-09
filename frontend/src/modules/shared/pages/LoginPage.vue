<template>
  <BaseCard>
    <div class="mb-6 space-y-1 text-center">
      <h1 class="text-2xl font-extrabold text-slate-800">Sign In</h1>
      <p class="text-sm text-slate-500">Access your account to continue shopping.</p>
    </div>

    <form class="space-y-4" @submit.prevent="submit">
      <BaseInput v-model="form.email" type="email" label="Email" placeholder="you@example.com" />
      <BaseInput
        v-model="form.password"
        type="password"
        label="Password"
        placeholder="Enter your password"
      />

      <p v-if="error" class="text-sm font-medium text-rose-600">{{ error }}</p>

      <BaseButton class="w-full" type="submit">
        <ArrowRightOnRectangleIcon class="h-4 w-4" />
        Login
      </BaseButton>
    </form>

    <p class="mt-5 text-center text-sm text-slate-600">
      New here?
      <router-link to="/register" class="font-semibold text-brightBlue">Create account</router-link>
    </p>
  </BaseCard>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ArrowRightOnRectangleIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import BaseButton from '@/components/base/BaseButton.vue'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const authStore = useAuthStore()
const uiStore = useUiStore()
const router = useRouter()

const form = reactive({
  email: '',
  password: '',
  device_name: 'vue-web',
})
const error = ref('')

async function submit() {
  error.value = ''
  try {
    await authStore.login(form)
    uiStore.pushToast('Login successful.', 'success')
    await router.push(authStore.isAdmin ? '/admin/dashboard' : '/app/catalog')
  } catch (requestError) {
    error.value =
      requestError.response?.data?.message ?? 'Unable to login with the provided credentials.'
  }
}
</script>
