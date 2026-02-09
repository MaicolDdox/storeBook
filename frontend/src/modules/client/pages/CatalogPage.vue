<template>
  <div class="space-y-5">
    <BaseCard>
      <div class="grid gap-3 sm:grid-cols-4">
        <BaseInput
          v-model="catalogStore.filters.search"
          label="Search"
          placeholder="Title, author, publisher"
          @keyup.enter="applyFilters"
        />
        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Category</span>
          <select
            v-model="catalogStore.filters.category_id"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm outline-none focus:border-brightBlue"
          >
            <option :value="null">All categories</option>
            <option
              v-for="category in catalogStore.categories"
              :key="category.id"
              :value="category.id"
            >
              {{ category.name }}
            </option>
          </select>
        </label>
        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Genre</span>
          <select
            v-model="catalogStore.filters.genre_id"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm outline-none focus:border-brightBlue"
          >
            <option :value="null">All genres</option>
            <option v-for="genre in catalogStore.genres" :key="genre.id" :value="genre.id">
              {{ genre.name }}
            </option>
          </select>
        </label>
        <div class="flex items-end gap-2">
          <BaseButton class="flex-1" @click="applyFilters">Filter</BaseButton>
          <BaseButton variant="secondary" class="flex-1" @click="resetFilters">Reset</BaseButton>
        </div>
      </div>
    </BaseCard>

    <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
      <BaseCard v-for="book in catalogStore.books" :key="book.id">
        <div class="flex h-full flex-col">
          <div class="mb-3 h-44 overflow-hidden rounded-xl bg-lightBlue">
            <img
              v-if="book.cover_image"
              :src="book.cover_image"
              :alt="book.title"
              class="h-full w-full object-cover"
            />
            <div
              v-else
              class="flex h-full items-center justify-center text-sm font-semibold text-slate-500"
            >
              No cover
            </div>
          </div>
          <h3 class="line-clamp-2 text-lg font-bold text-slate-800">{{ book.title }}</h3>
          <p class="mb-2 text-sm text-slate-500">{{ book.author }}</p>
          <p class="mb-4 line-clamp-3 text-sm text-slate-600">{{ book.description }}</p>

          <div class="mt-auto flex items-center justify-between">
            <p class="text-lg font-extrabold text-brightBlue">
              ${{ formatPrice(book.price_cents) }}
            </p>
            <div class="flex items-center gap-2">
              <router-link
                :to="`/app/books/${book.id}`"
                class="rounded-lg border border-sky-200 px-3 py-1.5 text-xs font-semibold text-slate-700"
              >
                Details
              </router-link>
              <BaseButton class="px-3 py-1.5" @click="addToCart(book.id)">
                <ShoppingCartIcon class="h-4 w-4" />
              </BaseButton>
            </div>
          </div>
        </div>
      </BaseCard>
    </div>

    <BaseCard v-if="catalogStore.books.length === 0">
      <p class="text-sm text-slate-600">No books found for the selected filters.</p>
    </BaseCard>

    <BasePagination :pagination="catalogStore.pagination" @change="changePage" />
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { ShoppingCartIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import BaseButton from '@/components/base/BaseButton.vue'
import BasePagination from '@/components/base/BasePagination.vue'
import { useCatalogStore } from '@/stores/catalog'
import { useCartStore } from '@/stores/cart'
import { useUiStore } from '@/stores/ui'

const catalogStore = useCatalogStore()
const cartStore = useCartStore()
const uiStore = useUiStore()

async function load() {
  await Promise.all([
    catalogStore.fetchCategories(),
    catalogStore.fetchGenres(),
    catalogStore.fetchBooks(),
  ])
}

function formatPrice(value) {
  return (value / 100).toFixed(2)
}

async function addToCart(bookId) {
  try {
    await cartStore.addItem(bookId, 1)
    uiStore.pushToast('Book added to cart.', 'success')
  } catch {
    uiStore.pushToast('Unable to add this book to your cart.', 'error')
  }
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
