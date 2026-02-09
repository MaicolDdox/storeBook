<template>
  <div class="space-y-4">
    <BaseCard>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-2xl font-extrabold text-slate-800">Manage Books</h1>
          <p class="text-sm text-slate-500">Create, update, and archive catalog books.</p>
        </div>
        <AppButton @click="openCreate">Add book</AppButton>
      </div>
    </BaseCard>

    <BaseTable>
      <template #head>
        <th class="px-4 py-3 font-semibold">Title</th>
        <th class="px-4 py-3 font-semibold">Type</th>
        <th class="px-4 py-3 font-semibold">Category</th>
        <th class="px-4 py-3 font-semibold">Price</th>
        <th class="px-4 py-3 font-semibold">Stock</th>
        <th class="px-4 py-3 font-semibold">Actions</th>
      </template>

      <template #body>
        <tr v-for="book in books" :key="book.id" class="border-t border-sky-50">
          <td class="px-4 py-3">
            <p class="font-semibold text-slate-800">{{ book.title }}</p>
            <p class="text-xs text-slate-500">{{ book.author }}</p>
          </td>
          <td class="px-4 py-3 text-sm text-slate-600">
            {{ book.category?.genre?.name ?? 'N/A' }}
          </td>
          <td class="px-4 py-3 text-sm text-slate-600">{{ book.category?.name }}</td>
          <td class="px-4 py-3 text-sm text-slate-600">
            ${{ (book.price_cents / 100).toFixed(2) }}
          </td>
          <td class="px-4 py-3 text-sm text-slate-600">{{ book.stock_quantity }}</td>
          <td class="px-4 py-3">
            <div class="flex gap-2">
              <AdminEditButton aria-label="Edit book" @click="openEdit(book)" />
              <AdminDeleteButton aria-label="Delete book" @click="confirmDelete(book.id)" />
            </div>
          </td>
        </tr>
      </template>
    </BaseTable>

    <BasePagination :pagination="pagination" @change="fetchBooks" />

    <BaseModal
      :open="modalOpen"
      :title="editingId ? 'Edit Book' : 'Create Book'"
      @close="closeModal"
    >
      <form class="grid gap-3 sm:grid-cols-2" @submit.prevent="submitForm">
        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Type</span>
          <select
            v-model.number="form.genre_id"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm text-slate-800"
            @change="syncCategoryWithGenre"
          >
            <option v-for="genre in genres" :key="genre.id" :value="genre.id">
              {{ genre.name }}
            </option>
          </select>
          <p v-if="fieldError('genre_id')" class="mt-1 text-xs font-medium text-red-600">
            {{ fieldError('genre_id') }}
          </p>
        </label>

        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Category</span>
          <select
            v-model.number="form.category_id"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm text-slate-800"
          >
            <option v-for="category in filteredCategories" :key="category.id" :value="category.id">
              {{ category.name }}
            </option>
          </select>
          <p v-if="fieldError('category_id')" class="mt-1 text-xs font-medium text-red-600">
            {{ fieldError('category_id') }}
          </p>
        </label>

        <BaseInput v-model="form.title" label="Title" />
        <p v-if="fieldError('title')" class="-mt-2 text-xs font-medium text-red-600">
          {{ fieldError('title') }}
        </p>

        <BaseInput v-model="form.author" label="Author" />
        <p v-if="fieldError('author')" class="-mt-2 text-xs font-medium text-red-600">
          {{ fieldError('author') }}
        </p>

        <BaseInput v-model="form.publisher" label="Publisher" />
        <BaseInput v-model.number="form.published_year" label="Year" type="number" />
        <BaseInput v-model.number="form.page_count" label="Page count" type="number" />
        <BaseInput v-model.number="form.stock_quantity" label="Stock" type="number" />
        <BaseInput v-model.number="form.price_cents" label="Price cents" type="number" />
        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Status</span>
          <select
            v-model="form.status"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm text-slate-800"
          >
            <option value="available">available</option>
            <option value="out_of_stock">out_of_stock</option>
            <option value="archived">archived</option>
          </select>
          <p v-if="fieldError('status')" class="mt-1 text-xs font-medium text-red-600">
            {{ fieldError('status') }}
          </p>
        </label>

        <div class="sm:col-span-2">
          <BaseInput v-model="form.description" label="Description" />
          <p v-if="fieldError('description')" class="mt-1 text-xs font-medium text-red-600">
            {{ fieldError('description') }}
          </p>
        </div>

        <div class="sm:col-span-2">
          <label class="block">
            <span class="mb-1 block text-sm font-medium text-slate-700">Cover image</span>
            <input
              class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm text-slate-700"
              type="file"
              accept="image/*"
              @change="handleImageChange"
            />
          </label>
          <p v-if="selectedImageName" class="mt-1 text-xs text-slate-500">
            Selected file: {{ selectedImageName }}
          </p>
          <p v-if="fieldError('image')" class="mt-1 text-xs font-medium text-red-600">
            {{ fieldError('image') }}
          </p>
          <div v-if="previewImageUrl" class="mt-3 flex items-center gap-3">
            <img
              :src="previewImageUrl"
              alt="Book cover preview"
              class="h-28 w-20 rounded-lg border border-sky-100 object-cover"
            />
            <AppButton type="button" variant="secondary" @click="clearImage"
              >Remove image</AppButton
            >
          </div>
        </div>

        <div class="sm:col-span-2 flex justify-end gap-2">
          <AppButton variant="secondary" type="button" @click="closeModal">Cancel</AppButton>
          <AppButton type="submit" :disabled="isSaving">{{
            editingId ? 'Save changes' : 'Create book'
          }}</AppButton>
        </div>
      </form>
    </BaseModal>
  </div>
</template>

<script setup>
import { computed, onBeforeUnmount, onMounted, reactive, ref } from 'vue'
import BaseCard from '@/components/base/BaseCard.vue'
import AppButton from '@/components/ui/AppButton.vue'
import AdminEditButton from '@/components/admin/AdminEditButton.vue'
import AdminDeleteButton from '@/components/admin/AdminDeleteButton.vue'
import BaseTable from '@/components/base/BaseTable.vue'
import BaseModal from '@/components/base/BaseModal.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import BasePagination from '@/components/base/BasePagination.vue'
import { http } from '@/services/http'
import { useUiStore } from '@/stores/ui'

const uiStore = useUiStore()

const books = ref([])
const categories = ref([])
const genres = ref([])
const pagination = ref({ current_page: 1, last_page: 1, per_page: 20, total: 0 })
const modalOpen = ref(false)
const editingId = ref(null)
const isSaving = ref(false)
const selectedImageFile = ref(null)
const selectedImageName = ref('')
const previewImageUrl = ref('')
const validationErrors = ref({})

const form = reactive({
  genre_id: null,
  category_id: null,
  title: '',
  description: '',
  author: '',
  publisher: '',
  published_year: null,
  page_count: null,
  stock_quantity: 1,
  price_cents: 1000,
  status: 'available',
  remove_image: false,
})

const filteredCategories = computed(() => {
  if (!form.genre_id) {
    return categories.value
  }

  return categories.value.filter((category) => category.genre?.id === form.genre_id)
})

function fieldError(fieldName) {
  const errors = validationErrors.value?.[fieldName]
  if (!Array.isArray(errors) || errors.length === 0) {
    return null
  }

  return errors[0]
}

function revokePreviewObjectUrl() {
  if (previewImageUrl.value && previewImageUrl.value.startsWith('blob:')) {
    URL.revokeObjectURL(previewImageUrl.value)
  }
}

function setPreviewImage(url) {
  revokePreviewObjectUrl()
  previewImageUrl.value = url || ''
}

function resetValidationErrors() {
  validationErrors.value = {}
}

function resetForm() {
  const defaultGenreId = genres.value[0]?.id ?? null
  const defaultCategories = categories.value.filter((item) => item.genre?.id === defaultGenreId)

  Object.assign(form, {
    genre_id: defaultGenreId,
    category_id: defaultCategories[0]?.id ?? categories.value[0]?.id ?? null,
    title: '',
    description: '',
    author: '',
    publisher: '',
    published_year: null,
    page_count: null,
    stock_quantity: 1,
    price_cents: 1000,
    status: 'available',
    remove_image: false,
  })

  selectedImageFile.value = null
  selectedImageName.value = ''
  setPreviewImage('')
  resetValidationErrors()
}

function syncCategoryWithGenre() {
  const nextCategory = filteredCategories.value.find((item) => item.id === form.category_id)
  if (!nextCategory) {
    form.category_id = filteredCategories.value[0]?.id ?? null
  }
}

function openCreate() {
  editingId.value = null
  resetForm()
  modalOpen.value = true
}

function openEdit(book) {
  editingId.value = book.id
  resetValidationErrors()
  selectedImageFile.value = null
  selectedImageName.value = ''

  Object.assign(form, {
    genre_id: book.category?.genre?.id ?? null,
    category_id: book.category?.id ?? null,
    title: book.title,
    description: book.description,
    author: book.author,
    publisher: book.publisher,
    published_year: book.published_year,
    page_count: book.page_count,
    stock_quantity: book.stock_quantity,
    price_cents: book.price_cents,
    status: book.status,
    remove_image: false,
  })

  syncCategoryWithGenre()
  setPreviewImage(book.cover_image_url ?? book.cover_image ?? '')
  modalOpen.value = true
}

function closeModal() {
  modalOpen.value = false
  resetValidationErrors()
}

function handleImageChange(event) {
  const file = event.target?.files?.[0]
  if (!file) {
    return
  }

  selectedImageFile.value = file
  selectedImageName.value = file.name
  form.remove_image = false
  setPreviewImage(URL.createObjectURL(file))
}

function clearImage() {
  selectedImageFile.value = null
  selectedImageName.value = ''
  setPreviewImage('')
  form.remove_image = true
}

function buildMultipartPayload() {
  const payload = new FormData()
  payload.append('category_id', String(form.category_id ?? ''))
  payload.append('title', form.title ?? '')
  payload.append('description', form.description ?? '')
  payload.append('author', form.author ?? '')
  payload.append('stock_quantity', String(form.stock_quantity ?? 0))
  payload.append('price_cents', String(form.price_cents ?? 0))
  payload.append('status', form.status ?? 'available')

  if (form.publisher) {
    payload.append('publisher', form.publisher)
  }
  if (form.published_year !== null && form.published_year !== '') {
    payload.append('published_year', String(form.published_year))
  }
  if (form.page_count !== null && form.page_count !== '') {
    payload.append('page_count', String(form.page_count))
  }
  if (selectedImageFile.value) {
    payload.append('image', selectedImageFile.value)
  }
  if (form.remove_image) {
    payload.append('remove_image', '1')
  }

  return payload
}

function resolveErrorMessage(error, fallbackMessage) {
  const errors = error?.validationErrors ?? {}
  const firstErrorGroup = Object.values(errors).find(
    (value) => Array.isArray(value) && value.length > 0,
  )
  if (firstErrorGroup) {
    return firstErrorGroup[0]
  }

  return error?.response?.data?.message ?? fallbackMessage
}

async function fetchBooks(page = 1) {
  const { data } = await http.get('/admin/books', { params: { page, per_page: 20 } })
  books.value = data.data
  pagination.value = data.meta?.pagination ?? pagination.value
}

async function fetchCategories() {
  const { data } = await http.get('/admin/categories', { params: { per_page: 100 } })
  categories.value = data.data
}

async function fetchGenres() {
  const { data } = await http.get('/admin/genres', { params: { per_page: 100 } })
  genres.value = data.data
}

async function submitForm() {
  isSaving.value = true
  resetValidationErrors()
  try {
    const payload = buildMultipartPayload()

    if (editingId.value) {
      payload.append('_method', 'PATCH')
      await http.post(`/admin/books/${editingId.value}`, payload, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      uiStore.pushToast('Book updated.', 'success')
    } else {
      await http.post('/admin/books', payload, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      uiStore.pushToast('Book created.', 'success')
    }

    closeModal()
    await fetchBooks(pagination.value.current_page)
  } catch (error) {
    validationErrors.value = error.validationErrors ?? {}
    uiStore.pushToast(resolveErrorMessage(error, 'Unable to save the book.'), 'error')
  } finally {
    isSaving.value = false
  }
}

async function confirmDelete(bookId) {
  const confirmed = window.confirm('Delete this book permanently?')
  if (!confirmed) {
    return
  }

  try {
    await http.delete(`/admin/books/${bookId}`)
    await fetchBooks(pagination.value.current_page)
    uiStore.pushToast('Book deleted.', 'success')
  } catch (error) {
    uiStore.pushToast(resolveErrorMessage(error, 'Unable to delete this book.'), 'error')
  }
}

onBeforeUnmount(() => {
  revokePreviewObjectUrl()
})

onMounted(async () => {
  await Promise.all([fetchGenres(), fetchCategories(), fetchBooks()])
  if (!form.genre_id && genres.value.length > 0) {
    form.genre_id = genres.value[0].id
  }
  syncCategoryWithGenre()
})
</script>
