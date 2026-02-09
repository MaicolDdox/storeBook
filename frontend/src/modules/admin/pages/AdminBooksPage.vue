<template>
  <div class="space-y-4">
    <BaseCard>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-2xl font-extrabold text-slate-800">Manage Books</h1>
          <p class="text-sm text-slate-500">Create, update, and archive catalog books.</p>
        </div>
        <BaseButton @click="openCreate">Add book</BaseButton>
      </div>
    </BaseCard>

    <BaseTable>
      <template #head>
        <th class="px-4 py-3 font-semibold">Title</th>
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
          <td class="px-4 py-3 text-sm text-slate-600">{{ book.category?.name }}</td>
          <td class="px-4 py-3 text-sm text-slate-600">
            ${{ (book.price_cents / 100).toFixed(2) }}
          </td>
          <td class="px-4 py-3 text-sm text-slate-600">{{ book.stock_quantity }}</td>
          <td class="px-4 py-3">
            <div class="flex gap-2">
              <BaseButton variant="secondary" class="px-2 py-1" @click="openEdit(book)"
                >Edit</BaseButton
              >
              <BaseButton variant="danger" class="px-2 py-1" @click="removeBook(book.id)"
                >Delete</BaseButton
              >
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
        <BaseInput v-model="form.title" label="Title" />
        <BaseInput v-model="form.author" label="Author" />
        <BaseInput v-model="form.publisher" label="Publisher" />
        <BaseInput v-model.number="form.published_year" label="Year" type="number" />
        <BaseInput v-model.number="form.page_count" label="Page count" type="number" />
        <BaseInput v-model.number="form.stock_quantity" label="Stock" type="number" />
        <BaseInput v-model.number="form.price_cents" label="Price cents" type="number" />
        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Category</span>
          <select
            v-model.number="form.category_id"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm"
          >
            <option v-for="category in categories" :key="category.id" :value="category.id">
              {{ category.name }}
            </option>
          </select>
        </label>
        <label class="block">
          <span class="mb-1 block text-sm font-medium text-slate-700">Status</span>
          <select
            v-model="form.status"
            class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm"
          >
            <option value="available">available</option>
            <option value="out_of_stock">out_of_stock</option>
            <option value="archived">archived</option>
          </select>
        </label>
        <div class="sm:col-span-2">
          <BaseInput v-model="form.description" label="Description" />
        </div>
        <div class="sm:col-span-2 flex justify-end gap-2">
          <BaseButton variant="secondary" type="button" @click="closeModal">Cancel</BaseButton>
          <BaseButton type="submit">{{ editingId ? 'Save changes' : 'Create book' }}</BaseButton>
        </div>
      </form>
    </BaseModal>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseButton from '@/components/base/BaseButton.vue'
import BaseTable from '@/components/base/BaseTable.vue'
import BaseModal from '@/components/base/BaseModal.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import BasePagination from '@/components/base/BasePagination.vue'
import { http } from '@/services/http'
import { useUiStore } from '@/stores/ui'

const uiStore = useUiStore()

const books = ref([])
const categories = ref([])
const pagination = ref({ current_page: 1, last_page: 1, per_page: 20, total: 0 })
const modalOpen = ref(false)
const editingId = ref(null)

const form = reactive({
  category_id: null,
  title: '',
  cover_image: '',
  description: '',
  author: '',
  publisher: '',
  published_year: null,
  page_count: null,
  stock_quantity: 1,
  price_cents: 1000,
  status: 'available',
})

function resetForm() {
  Object.assign(form, {
    category_id: categories.value[0]?.id ?? null,
    title: '',
    cover_image: '',
    description: '',
    author: '',
    publisher: '',
    published_year: null,
    page_count: null,
    stock_quantity: 1,
    price_cents: 1000,
    status: 'available',
  })
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

function openCreate() {
  editingId.value = null
  resetForm()
  modalOpen.value = true
}

function openEdit(book) {
  editingId.value = book.id
  Object.assign(form, {
    category_id: book.category?.id ?? null,
    title: book.title,
    cover_image: book.cover_image,
    description: book.description,
    author: book.author,
    publisher: book.publisher,
    published_year: book.published_year,
    page_count: book.page_count,
    stock_quantity: book.stock_quantity,
    price_cents: book.price_cents,
    status: book.status,
  })
  modalOpen.value = true
}

function closeModal() {
  modalOpen.value = false
}

async function submitForm() {
  try {
    if (editingId.value) {
      await http.patch(`/admin/books/${editingId.value}`, form)
      uiStore.pushToast('Book updated.', 'success')
    } else {
      await http.post('/admin/books', form)
      uiStore.pushToast('Book created.', 'success')
    }

    closeModal()
    await fetchBooks(pagination.value.current_page)
  } catch {
    uiStore.pushToast('Unable to save the book.', 'error')
  }
}

async function removeBook(bookId) {
  try {
    await http.delete(`/admin/books/${bookId}`)
    await fetchBooks(pagination.value.current_page)
    uiStore.pushToast('Book deleted.', 'success')
  } catch {
    uiStore.pushToast('Unable to delete this book.', 'error')
  }
}

onMounted(async () => {
  await Promise.all([fetchCategories(), fetchBooks()])
  if (!form.category_id && categories.value.length > 0) {
    form.category_id = categories.value[0].id
  }
})
</script>
