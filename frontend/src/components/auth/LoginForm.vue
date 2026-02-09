<template>
  <form class="space-y-4" @submit.prevent="submit">
    <BaseInput v-model="form.email" type="email" label="Email" placeholder="you@example.com" />
    <BaseInput
      v-model="form.password"
      type="password"
      label="Password"
      placeholder="Enter your password"
    />

    <p v-if="error" class="text-sm font-medium text-rose-600">{{ error }}</p>

    <AppButton class="w-full" type="submit" :disabled="loading">
      <ArrowRightOnRectangleIcon class="h-4 w-4" />
      Login
    </AppButton>
  </form>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { ArrowRightOnRectangleIcon } from '@heroicons/vue/24/solid'
import BaseInput from '@/components/base/BaseInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()

const form = reactive({
  email: '',
  password: '',
  device_name: 'vue-web',
})
const error = ref('')
const loading = ref(false)

const emit = defineEmits(['success'])

async function submit() {
  error.value = ''
  loading.value = true
  try {
    await authStore.login(form)
    emit('success')
  } catch (requestError) {
    error.value =
      requestError.response?.data?.message ?? 'Unable to login with the provided credentials.'
  } finally {
    loading.value = false
  }
}
</script>
