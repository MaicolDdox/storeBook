<template>
  <div class="space-y-5">
    <CatalogFilters
      :filters="catalogStore.filters"
      :categories="catalogStore.categories"
      :genres="catalogStore.genres"
      @apply="applyFilters"
      @reset="resetFilters"
      @update:search="catalogStore.filters.search = $event"
      @update:categoryId="catalogStore.filters.category_id = $event"
      @update:genreId="catalogStore.filters.genre_id = $event"
    />

    <CatalogSkeleton v-if="catalogStore.loading && catalogStore.books.length === 0" />
    <CatalogError
      v-else-if="catalogStore.error && catalogStore.books.length === 0"
      :message="catalogStore.error"
      @retry="load"
    />
    <BookGrid
      v-else
      :books="catalogStore.books"
      :loading-item-id="loadingItemId"
      @add-to-cart="handleAddToCart"
    />

    <CatalogEmpty v-if="!catalogStore.loading && !catalogStore.error && catalogStore.books.length === 0" />

    <BasePagination
      v-if="catalogStore.books.length > 0"
      :pagination="catalogStore.pagination"
      @change="changePage"
    />
  </div>
</template>

<script setup>
import { onMounted, ref } from 'vue'
import BookGrid from '@/components/catalog/BookGrid.vue'
import CatalogFilters from '@/components/catalog/CatalogFilters.vue'
import CatalogEmpty from '@/components/catalog/CatalogEmpty.vue'
import CatalogSkeleton from '@/components/catalog/CatalogSkeleton.vue'
import CatalogError from '@/components/catalog/CatalogError.vue'
import BasePagination from '@/components/base/BasePagination.vue'
import { useCatalogStore } from '@/stores/catalog'
import { useCartStore } from '@/stores/cart'
import { useUiStore } from '@/stores/ui'
import { useRequireAuthAction } from '@/composables/useRequireAuthAction'

const catalogStore = useCatalogStore()
const cartStore = useCartStore()
const uiStore = useUiStore()
const { executeWithAuth } = useRequireAuthAction()
const loadingItemId = ref(null)

async function load() {
  await Promise.all([
    catalogStore.fetchCategories(),
    catalogStore.fetchGenres(),
    catalogStore.fetchBooks(),
  ])
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

async function applyFilters() {
  catalogStore.filters.page = 1
  await catalogStore.fetchBooks()
}

async function resetFilters() {
  catalogStore.resetFilters()
  await catalogStore.fetchBooks()
}

async function changePage(page) {
  catalogStore.setPage(page)
  await catalogStore.fetchBooks()
}

onMounted(load)
</script>
