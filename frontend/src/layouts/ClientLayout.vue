<template>
  <div class="min-h-screen bg-lightBlue">
    <header class="border-b border-sky-100 bg-white/90 backdrop-blur-sm">
      <div class="mx-auto flex w-full max-w-7xl items-center justify-between px-4 py-3 sm:px-6">
        <router-link to="/" class="text-lg font-extrabold text-slate-800"> StoreBook </router-link>

        <nav class="hidden items-center gap-2 sm:flex">
          <router-link
            v-for="item in navLinks"
            :key="item.to"
            :to="item.to"
            class="rounded-xl px-3 py-2 text-sm font-semibold text-slate-700 transition hover:bg-lightBlue hover:text-slate-900"
          >
            {{ item.label }}
          </router-link>
        </nav>

        <div class="flex items-center gap-2">
          <router-link
            v-if="authStore.isAdmin"
            to="/admin/dashboard"
            class="inline-flex items-center justify-center rounded-xl border-2 border-transparent border-brightBlue px-5 py-2.5 text-sm font-bold text-brightBlue transition hover:bg-lightBlue"
          >
            Admin
          </router-link>
          <AppButton v-if="authStore.isAuthenticated" class="text-xs" @click="logout">
            Logout
          </AppButton>
        </div>
      </div>

      <div
        class="mx-auto flex w-full max-w-7xl items-center gap-2 overflow-x-auto px-4 pb-3 sm:hidden"
      >
        <router-link
          v-for="item in navLinks"
          :key="item.to"
          :to="item.to"
          class="whitespace-nowrap rounded-lg bg-brightBlue px-3 py-1.5 text-xs font-semibold text-white transition hover:bg-[#0097c9]"
        >
          {{ item.label }}
        </router-link>
      </div>
    </header>

    <main class="mx-auto w-full max-w-7xl p-4 sm:p-6">
      <router-view />
    </main>

    <ToastStack />
    <GlobalLoader />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'
import ToastStack from '@/components/feedback/ToastStack.vue'
import GlobalLoader from '@/components/feedback/GlobalLoader.vue'
import AppButton from '@/components/ui/AppButton.vue'

const authStore = useAuthStore()
const uiStore = useUiStore()
const router = useRouter()

const navLinks = computed(() => {
  const base = [
    { label: 'Home', to: '/' },
    { label: 'Catalog', to: '/catalog' },
  ]
  if (authStore.isAuthenticated) {
    return [...base, { label: 'Cart', to: '/cart' }, { label: 'Orders', to: '/orders' }]
  }
  return [...base, { label: 'Login', to: '/login' }, { label: 'Register', to: '/register' }]
})

async function logout() {
  await authStore.logout()
  uiStore.pushToast('Signed out successfully.', 'success')
  await router.push({ name: 'login' })
}
</script>
