<template>
  <div class="space-y-12 pb-8">
    <section>
      <HeroCarousel />
    </section>

    <section class="flex flex-col items-center gap-4">
      <div class="flex w-full max-w-2xl gap-2">
        <BaseInput
          v-model="searchQuery"
          placeholder="Search books by title, author, or publisher..."
          class="flex-1"
          @keyup.enter="goToCatalog"
        />
        <AppButton @click="goToCatalog">Search</AppButton>
      </div>
      <router-link
        to="/catalog"
        class="text-sm font-semibold text-brightBlue hover:underline"
      >
        Browse full catalog
      </router-link>
    </section>

    <section>
      <div class="mb-6 flex items-center justify-between">
        <h2 class="text-xl font-extrabold text-slate-800">New Arrivals</h2>
        <router-link
          to="/catalog"
          class="text-sm font-semibold text-brightBlue hover:underline"
        >
          View all
        </router-link>
      </div>

      <CatalogSkeleton v-if="catalogStore.loading && catalogStore.books.length === 0" />
      <CatalogError
        v-else-if="catalogStore.error && catalogStore.books.length === 0"
        :message="catalogStore.error"
        @retry="loadPreview"
      />
      <BookGrid
        v-else
        :books="catalogStore.books"
        :loading-item-id="loadingItemId"
        @add-to-cart="handleAddToCart"
      />
      <CatalogEmpty
        v-if="!catalogStore.loading && !catalogStore.error && catalogStore.books.length === 0"
        message="No books available yet."
        :show-reset="false"
      />
    </section>

    <section class="rounded-2xl bg-white p-8 text-center shadow-panel">
      <h2 class="text-xl font-extrabold text-slate-800">Ready to explore?</h2>
      <p class="mt-2 text-slate-600">
        Create an account to add books to your cart and complete your purchase.
      </p>
      <div class="mt-6 flex flex-wrap justify-center gap-3">
        <router-link
          v-if="!authStore.isAuthenticated"
          to="/login"
          class="inline-flex items-center justify-center rounded-xl border border-transparent bg-brightBlue px-5 py-2.5 text-sm font-bold text-white transition hover:bg-[#0097c9]"
        >
          Sign in
        </router-link>
        <router-link
          v-if="!authStore.isAuthenticated"
          to="/register"
          class="inline-flex items-center justify-center rounded-xl border-2 border-brightBlue bg-white px-5 py-2.5 text-sm font-bold text-brightBlue transition hover:bg-lightBlue"
        >
          Create account
        </router-link>
        <router-link
          v-if="authStore.isAuthenticated"
          to="/catalog"
          class="inline-flex items-center justify-center rounded-xl border border-transparent bg-brightBlue px-5 py-2.5 text-sm font-bold text-white transition hover:bg-[#0097c9]"
        >
          Browse catalog
        </router-link>
      </div>
    </section>
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import HeroCarousel from '@/components/home/HeroCarousel.vue'
import BookGrid from '@/components/catalog/BookGrid.vue'
import CatalogEmpty from '@/components/catalog/CatalogEmpty.vue'
import CatalogSkeleton from '@/components/catalog/CatalogSkeleton.vue'
import CatalogError from '@/components/catalog/CatalogError.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import AppButton from '@/components/ui/AppButton.vue'
import { useCatalogStore } from '@/stores/catalog'
import { useCartStore } from '@/stores/cart'
import { useAuthStore } from '@/stores/auth'
import { useUiStore } from '@/stores/ui'
import { useRequireAuthAction } from '@/composables/useRequireAuthAction'

const router = useRouter()
const catalogStore = useCatalogStore()
const cartStore = useCartStore()
const authStore = useAuthStore()
const uiStore = useUiStore()
const { executeWithAuth } = useRequireAuthAction()
const searchQuery = ref('')
const loadingItemId = ref(null)

async function loadPreview() {
  catalogStore.resetFilters()
  catalogStore.filters.per_page = 8
  catalogStore.filters.sort = 'newest'
  await Promise.all([
    catalogStore.fetchCategories(),
    catalogStore.fetchGenres(),
    catalogStore.fetchBooks(),
  ])
}

function goToCatalog() {
  catalogStore.filters.search = searchQuery.value
  catalogStore.filters.page = 1
  router.push({ name: 'catalog' })
}

async function handleAddToCart(bookId) {
  await executeWithAuth(
    async () => {
      loadingItemId.value = bookId
      try {
        await cartStore.addItem(bookId, 1)
        uiStore.pushToast('Book added to cart.', 'success')
      } catch {
        uiStore.pushToast('Unable to add this book to your cart.', 'error')
      } finally {
        loadingItemId.value = null
      }
    },
    { bookId, action: 'add-to-cart' },
  )
}

onMounted(loadPreview)
</script>
