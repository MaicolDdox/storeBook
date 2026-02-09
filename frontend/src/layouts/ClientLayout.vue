<template>
  <div class="min-h-screen bg-lightBlue">
    <header class="border-b border-sky-100 bg-white/90 backdrop-blur-sm">
      <div class="mx-auto flex w-full max-w-7xl items-center justify-between px-4 py-3 sm:px-6">
        <router-link to="/app/catalog" class="text-lg font-extrabold text-slate-800">
          StoreBook
        </router-link>

        <nav class="hidden items-center gap-2 sm:flex">
          <router-link
            v-for="item in links"
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
            class="rounded-lg border border-sky-200 px-3 py-2 text-xs font-semibold text-slate-700"
          >
            Admin
          </router-link>
          <BaseButton class="text-xs" @click="logout">Logout</BaseButton>
        </div>
      </div>

      <div
        class="mx-auto flex w-full max-w-7xl items-center gap-2 overflow-x-auto px-4 pb-3 sm:hidden"
      >
        <router-link
          v-for="item in links"
          :key="item.to"
          :to="item.to"
          class="whitespace-nowrap rounded-lg bg-white px-3 py-1.5 text-xs font-semibold text-slate-700"
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
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'
import ToastStack from '@/components/feedback/ToastStack.vue'
import GlobalLoader from '@/components/feedback/GlobalLoader.vue'
import BaseButton from '@/components/base/BaseButton.vue'

const authStore = useAuthStore()
const uiStore = useUiStore()
const router = useRouter()

const links = [
  { label: 'Catalog', to: '/app/catalog' },
  { label: 'Cart', to: '/app/cart' },
  { label: 'Orders', to: '/app/orders' },
]

async function logout() {
  await authStore.logout()
  uiStore.pushToast('Signed out successfully.', 'success')
  await router.push({ name: 'login' })
}
</script>
