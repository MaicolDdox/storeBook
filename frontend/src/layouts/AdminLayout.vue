<template>
  <div class="min-h-screen bg-lightBlue">
    <div
      class="mx-auto grid min-h-screen w-full max-w-7xl grid-cols-1 gap-4 p-4 sm:grid-cols-[230px_1fr] sm:p-6"
    >
      <aside class="rounded-2xl bg-white p-4 shadow-panel">
        <div class="mb-4 border-b border-sky-100 pb-3">
          <h1 class="text-lg font-extrabold text-slate-800">Admin Panel</h1>
          <p class="text-xs text-slate-500">{{ authStore.user?.email }}</p>
        </div>

        <nav class="space-y-2">
          <router-link
            v-for="item in links"
            :key="item.to"
            :to="item.to"
            class="flex items-center gap-2 rounded-xl px-3 py-2 text-sm font-semibold text-slate-700 transition hover:bg-lightBlue"
          >
            <component :is="item.icon" class="h-4 w-4" />
            {{ item.label }}
          </router-link>
        </nav>

        <div class="mt-6 space-y-2">
          <router-link
            to="/"
            class="block rounded-xl border border-brightBlue bg-[#0097c9] px-3 py-2 text-center text-xs font-semibold text-white"
          >
            Open Client Area
          </router-link>
          <AppButton class="w-full text-xs" @click="logout">Logout</AppButton>
        </div>
      </aside>

      <main class="space-y-4">
        <router-view />
      </main>
    </div>

    <ToastStack />
    <GlobalLoader />
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import {
  Squares2X2Icon,
  BookOpenIcon,
  RectangleStackIcon,
  TagIcon,
  ClipboardDocumentListIcon,
} from '@heroicons/vue/24/solid'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'
import ToastStack from '@/components/feedback/ToastStack.vue'
import GlobalLoader from '@/components/feedback/GlobalLoader.vue'
import AppButton from '@/components/ui/AppButton.vue'

const authStore = useAuthStore()
const uiStore = useUiStore()
const router = useRouter()

const links = [
  { label: 'Dashboard', to: '/admin/dashboard', icon: Squares2X2Icon },
  { label: 'Types', to: '/admin/types', icon: RectangleStackIcon },
  { label: 'Books', to: '/admin/books', icon: BookOpenIcon },
  { label: 'Categories', to: '/admin/categories', icon: TagIcon },
  { label: 'Orders', to: '/admin/orders', icon: ClipboardDocumentListIcon },
]

async function logout() {
  await authStore.logout()
  uiStore.pushToast('Signed out successfully.', 'success')
  await router.push({ name: 'login' })
}
</script>
