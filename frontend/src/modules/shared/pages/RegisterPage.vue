<template>
  <BaseCard>
    <div class="mb-6 space-y-1 text-center">
      <h1 class="text-2xl font-extrabold text-slate-800">Create Account</h1>
      <p class="text-sm text-slate-500">Join StoreBook and start your next read.</p>
    </div>

    <form class="space-y-4" @submit.prevent="submit">
      <BaseInput v-model="form.name" label="Full name" placeholder="Jane Reader" />
      <BaseInput v-model="form.email" type="email" label="Email" placeholder="you@example.com" />
      <BaseInput
        v-model="form.password"
        type="password"
        label="Password"
        placeholder="At least 8 characters"
      />

      <p v-if="error" class="text-sm font-medium text-rose-600">{{ error }}</p>

      <BaseButton class="w-full" type="submit">
        <UserPlusIcon class="h-4 w-4" />
        Register
      </BaseButton>
    </form>

    <p class="mt-5 text-center text-sm text-slate-600">
      Already registered?
      <router-link to="/login" class="font-semibold text-brightBlue">Sign in</router-link>
    </p>
  </BaseCard>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { UserPlusIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import BaseButton from '@/components/base/BaseButton.vue'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'

const authStore = useAuthStore()
const uiStore = useUiStore()
const router = useRouter()

const form = reactive({
  name: '',
  email: '',
  password: '',
  device_name: 'vue-web',
})
const error = ref('')

async function submit() {
  error.value = ''
  try {
    await authStore.register(form)
    uiStore.pushToast('Account created successfully.', 'success')
    await router.push('/app/catalog')
  } catch (requestError) {
    error.value = requestError.response?.data?.message ?? 'Unable to register this account.'
  }
}
</script>
