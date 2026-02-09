<template>
  <div class="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
    <BookCard
      v-for="book in books"
      :key="book.id"
      :book="book"
      :loading="loadingItemId === book.id"
      @add-to-cart="$emit('add-to-cart', $event)"
    />
  </div>
</template>

<script setup>
import BookCard from '@/components/catalog/BookCard.vue'

defineProps({
  books: {
    type: Array,
    default: () => [],
  },
  loadingItemId: {
    type: [Number, String],
    default: null,
  },
})

defineEmits(['add-to-cart'])
</script>
