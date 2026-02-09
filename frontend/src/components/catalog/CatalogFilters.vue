<template>
  <BaseCard>
    <div class="grid gap-3 sm:grid-cols-4">
      <BaseInput
        :model-value="filters.search"
        label="Search"
        placeholder="Title, author, publisher"
        @update:modelValue="$emit('update:search', $event)"
        @keyup.enter="$emit('apply')"
      />
      <label class="block">
        <span class="mb-1 block text-sm font-medium text-slate-700">Category</span>
        <select
          :value="filters.category_id"
          class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm outline-none focus:border-brightBlue"
          @change="
            $emit('update:categoryId', $event.target.value ? Number($event.target.value) : null)
          "
        >
          <option :value="null">All categories</option>
          <option v-for="category in categories" :key="category.id" :value="category.id">
            {{ category.name }}
          </option>
        </select>
      </label>
      <label class="block">
        <span class="mb-1 block text-sm font-medium text-slate-700">Genre</span>
        <select
          :value="filters.genre_id"
          class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm outline-none focus:border-brightBlue"
          @change="
            $emit('update:genreId', $event.target.value ? Number($event.target.value) : null)
          "
        >
          <option :value="null">All genres</option>
          <option v-for="genre in genres" :key="genre.id" :value="genre.id">
            {{ genre.name }}
          </option>
        </select>
      </label>
      <div class="flex items-end gap-2">
        <AppButton class="flex-1" @click="$emit('apply')">Filter</AppButton>
        <AppButton variant="secondary" class="flex-1" @click="$emit('reset')"> Reset </AppButton>
      </div>
    </div>
  </BaseCard>
</template>

<script setup>
import BaseCard from '@/components/base/BaseCard.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import AppButton from '@/components/ui/AppButton.vue'

defineProps({
  filters: {
    type: Object,
    required: true,
  },
  categories: {
    type: Array,
    default: () => [],
  },
  genres: {
    type: Array,
    default: () => [],
  },
})

defineEmits(['apply', 'reset', 'update:search', 'update:categoryId', 'update:genreId'])
</script>
