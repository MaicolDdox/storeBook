<template>
  <div class="space-y-4">
    <BaseCard>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-2xl font-extrabold text-slate-800">Manage Categories</h1>
          <p class="text-sm text-slate-500">Organize the catalog using genres and categories.</p>
        </div>
        <AppButton @click="openCreate">Add category</AppButton>
      </div>
    </BaseCard>

    <BaseTable>
      <template #head>
        <th class="px-4 py-3 font-semibold">Name</th>
        <th class="px-4 py-3 font-semibold">Genre</th>
        <th class="px-4 py-3 font-semibold">Actions</th>
      </template>

      <template #body>
        <tr v-for="category in categories" :key="category.id" class="border-t border-sky-50">
          <td class="px-4 py-3">
            <p class="font-semibold text-slate-800">{{ category.name }}</p>
            <p class="text-xs text-slate-500">{{ category.slug }}</p>
          </td>
          <td class="px-4 py-3 text-sm text-slate-600">{{ category.genre?.name }}</td>
          <td class="px-4 py-3">
            <div class="flex gap-2">
              <AdminEditButton aria-label="Edit category" @click="openEdit(category)" />
              <AdminDeleteButton aria-label="Delete category" @click="removeCategory(category.id)" />
            </div>
          </td>
        </tr>
      </template>
    </BaseTable>

    <BasePagination :pagination="pagination" @change="fetchCategories" />

    <BaseModal
      :open="modalOpen"
      :title="editingId ? 'Edit category' : 'Create category'"
      @close="closeModal"
    >
      <form class="space-y-3" @submit.prevent="submitForm">
        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Genre</span>
          <select
            v-model.number="form.genre_id"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm"
          >
            <option v-for="genre in genres" :key="genre.id" :value="genre.id">
              {{ genre.name }}
            </option>
          </select>
        </label>

        <BaseInput v-model="form.name" label="Name" />
        <BaseInput v-model="form.description" label="Description" />

        <div class="flex justify-end gap-2">
          <AppButton variant="secondary" type="button" @click="closeModal">Cancel</AppButton>
          <AppButton type="submit">{{
            editingId ? 'Save changes' : 'Create category'
          }}</AppButton>
        </div>
      </form>
    </BaseModal>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import BaseCard from '@/components/base/BaseCard.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AdminEditButton from '@/components/admin/AdminEditButton.vue'
import AdminDeleteButton from '@/components/admin/AdminDeleteButton.vue'
import BaseTable from '@/components/base/BaseTable.vue'
import BasePagination from '@/components/base/BasePagination.vue'
import BaseModal from '@/components/base/BaseModal.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import { http } from '@/services/http'
import { useUiStore } from '@/stores/ui'

const uiStore = useUiStore()
const categories = ref([])
const genres = ref([])
const pagination = ref({ current_page: 1, last_page: 1, per_page: 20, total: 0 })
const modalOpen = ref(false)
const editingId = ref(null)

const form = reactive({
  genre_id: null,
  name: '',
  description: '',
})

function resetForm() {
  Object.assign(form, {
    genre_id: genres.value[0]?.id ?? null,
    name: '',
    description: '',
  })
}

async function fetchCategories(page = 1) {
  const { data } = await http.get('/admin/categories', { params: { page, per_page: 20 } })
  categories.value = data.data
  pagination.value = data.meta?.pagination ?? pagination.value
}

async function fetchGenres() {
  const { data } = await http.get('/admin/genres', { params: { per_page: 100 } })
  genres.value = data.data
}

function openCreate() {
  editingId.value = null
  resetForm()
  modalOpen.value = true
}

function openEdit(category) {
  editingId.value = category.id
  Object.assign(form, {
    genre_id: category.genre?.id ?? null,
    name: category.name,
    description: category.description,
  })
  modalOpen.value = true
}

function closeModal() {
  modalOpen.value = false
}

async function submitForm() {
  try {
    if (editingId.value) {
      await http.patch(`/admin/categories/${editingId.value}`, form)
      uiStore.pushToast('Category updated.', 'success')
    } else {
      await http.post('/admin/categories', form)
      uiStore.pushToast('Category created.', 'success')
    }

    closeModal()
    await fetchCategories(pagination.value.current_page)
  } catch {
    uiStore.pushToast('Unable to save this category.', 'error')
  }
}

async function removeCategory(categoryId) {
  try {
    await http.delete(`/admin/categories/${categoryId}`)
    await fetchCategories(pagination.value.current_page)
    uiStore.pushToast('Category deleted.', 'success')
  } catch {
    uiStore.pushToast('Unable to delete this category.', 'error')
  }
}

onMounted(async () => {
  await Promise.all([fetchGenres(), fetchCategories()])
  if (!form.genre_id && genres.value.length > 0) {
    form.genre_id = genres.value[0].id
  }
})
</script>
