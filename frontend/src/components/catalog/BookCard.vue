<template>
  <BaseCard class="flex h-full flex-col">
    <div class="mb-3 h-44 overflow-hidden rounded-xl bg-lightBlue">
      <img
        :src="coverSource"
        :alt="`Cover image for ${book.title}`"
        class="h-full w-full object-cover"
        @error="handleCoverImageError"
      />
    </div>
    <h3 class="line-clamp-2 text-lg font-bold text-slate-800">{{ book.title }}</h3>
    <p class="mb-2 text-sm text-slate-500">{{ book.author }}</p>
    <p class="mb-4 line-clamp-3 text-sm text-slate-600">{{ book.description }}</p>

    <div class="mt-auto flex items-center justify-between">
      <p class="text-lg font-extrabold text-brightBlue">${{ formatPrice(book.price_cents) }}</p>
      <div class="flex items-center gap-2">
        <router-link
          :to="{ name: 'book-detail', params: { id: book.id } }"
          class="rounded-lg border border-brightBlue bg-[#0097c9] px-3 py-1.5 text-xs font-semibold text-white"
        >
          Details
        </router-link>
        <button
          type="button"
          class="inline-flex items-center justify-center gap-1 rounded-xl border border-transparent bg-[#0097c9] px-3 py-1.5 text-xs font-bold text-white transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brightBlue disabled:cursor-not-allowed disabled:opacity-60"
          :disabled="loading"
          :aria-label="`Add ${book.title} to cart`"
          @click="$emit('add-to-cart', book.id)"
        >
          <ShoppingCartIcon class="h-4 w-4" />
        </button>
      </div>
    </div>
  </BaseCard>
</template>

<script setup>
import { computed } from 'vue'
import { ShoppingCartIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'
import { resolveAssetUrl } from '@/shared/utils/resolveAssetUrl'

const PLACEHOLDER_COVER = '/images/placeholders/book-cover.png'

const props = defineProps({
  book: {
    type: Object,
    required: true,
  },
  loading: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['add-to-cart'])

const coverSource = computed(() => {
  return (
    resolveAssetUrl(
      props.book.coverImageUrl ?? props.book.cover_image_url ?? props.book.cover_image,
    ) ?? PLACEHOLDER_COVER
  )
})

function formatPrice(value) {
  return (value / 100).toFixed(2)
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
</script>
