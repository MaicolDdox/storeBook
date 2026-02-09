<template>
  <BaseCard class="flex h-full flex-col">
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
          :to="{ name: 'book-detail', params: { id: book.id } }"
          class="rounded-lg border border-brightBlue bg-brightBlue px-3 py-1.5 text-xs font-semibold text-white transition hover:bg-[#0097c9]"
        >
          Details
        </router-link>
        <button
          type="button"
          class="inline-flex items-center justify-center gap-1 rounded-xl border border-transparent bg-brightBlue px-3 py-1.5 text-xs font-bold text-white transition hover:bg-[#0097c9] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-brightBlue disabled:cursor-not-allowed disabled:opacity-60"
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
import { ShoppingCartIcon } from '@heroicons/vue/24/solid'
import BaseCard from '@/components/base/BaseCard.vue'

defineProps({
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

function formatPrice(value) {
  return (value / 100).toFixed(2)
}
</script>
