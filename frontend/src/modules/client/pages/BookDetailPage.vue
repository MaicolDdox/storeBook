<template>
  <BaseCard v-if="catalogStore.currentBook">
    <div class="grid gap-6 md:grid-cols-[280px_1fr]">
      <div class="h-72 overflow-hidden rounded-xl bg-lightBlue">
        <img
          :src="coverSource"
          :alt="`Cover image for ${catalogStore.currentBook.title}`"
          class="h-full w-full object-cover"
          @error="handleCoverImageError"
        />
      </div>

      <div class="space-y-3">
        <h1 class="text-2xl font-extrabold text-slate-800">{{ catalogStore.currentBook.title }}</h1>
        <p class="text-sm text-slate-500">{{ catalogStore.currentBook.author }}</p>
        <p class="text-sm text-slate-600">{{ catalogStore.currentBook.description }}</p>

        <div class="grid gap-2 text-sm text-slate-600 sm:grid-cols-2">
          <p><strong>Publisher:</strong> {{ catalogStore.currentBook.publisher || 'N/A' }}</p>
          <p><strong>Year:</strong> {{ catalogStore.currentBook.published_year || 'N/A' }}</p>
          <p><strong>Pages:</strong> {{ catalogStore.currentBook.page_count || 'N/A' }}</p>
          <p><strong>Stock:</strong> {{ catalogStore.currentBook.stock_quantity }}</p>
        </div>

        <div class="flex flex-wrap items-center gap-3 pt-3">
          <p class="text-2xl font-extrabold text-brightBlue">
            ${{ (catalogStore.currentBook.price_cents / 100).toFixed(2) }}
          </p>
          <label class="flex items-center gap-2 text-sm">
            Qty
            <input
              v-model.number="quantity"
              type="number"
              min="1"
              class="w-20 rounded-lg border border-sky-100 bg-white px-2 py-1 text-slate-800"
            />
          </label>
          <div class="flex gap-2">
            <AppButton :disabled="adding" @click="addToCart">
              <ShoppingCartIcon class="h-4 w-4" />
              Add to cart
            </AppButton>
            <AppButton variant="secondary" :disabled="adding" @click="buyNow"> Buy now </AppButton>
          </div>
        </div>
      </div>
    </div>
  </BaseCard>
</template>

<script setup>
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ShoppingCartIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'
import AppButton from '@/components/ui/AppButton.vue'
import { useCatalogStore } from '@/stores/catalog'
import { useCartStore } from '@/stores/cart'
import { useUiStore } from '@/stores/ui'
import { useRequireAuthAction } from '@/composables/useRequireAuthAction'
import { resolveAssetUrl } from '@/shared/utils/resolveAssetUrl'

const route = useRoute()
const router = useRouter()
const catalogStore = useCatalogStore()
const cartStore = useCartStore()
const uiStore = useUiStore()
const { executeWithAuth } = useRequireAuthAction()
const quantity = ref(1)
const adding = ref(false)
const PLACEHOLDER_COVER = '/images/placeholders/book-cover.png'

const coverSource = computed(() => {
  const book = catalogStore.currentBook
  if (!book) {
    return PLACEHOLDER_COVER
  }

  return (
    resolveAssetUrl(book.coverImageUrl ?? book.cover_image_url ?? book.cover_image) ??
    PLACEHOLDER_COVER
  )
})

async function doAddToCart() {
  adding.value = true
  try {
    await cartStore.addItem(catalogStore.currentBook.id, quantity.value)
    uiStore.pushToast('Book added to cart.', 'success')
  } catch {
    uiStore.pushToast('Unable to add this quantity to cart.', 'error')
  } finally {
    adding.value = false
  }
}

function addToCart() {
  executeWithAuth(doAddToCart, { bookId: catalogStore.currentBook?.id, action: 'add-to-cart' })
}

async function doBuyNow() {
  adding.value = true
  try {
    await cartStore.addItem(catalogStore.currentBook.id, quantity.value)
    uiStore.pushToast('Book added to cart.', 'success')
    await router.push({ name: 'checkout' })
  } catch {
    uiStore.pushToast('Unable to add this quantity to cart.', 'error')
  } finally {
    adding.value = false
  }
}

function buyNow() {
  executeWithAuth(doBuyNow, { bookId: catalogStore.currentBook?.id, action: 'buy-now' })
}

function handleCoverImageError(event) {
  const imageElement = event.target
  if (!(imageElement instanceof HTMLImageElement)) {
    return
  }

  if (imageElement.dataset.fallbackApplied === 'true') {
    return
  }

  imageElement.dataset.fallbackApplied = 'true'
  imageElement.src = PLACEHOLDER_COVER
}

onMounted(async () => {
  await catalogStore.fetchBook(route.params.id)
})
</script>
