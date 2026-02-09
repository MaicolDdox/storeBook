<template>
  <div class="space-y-4">
    <BaseCard>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-2xl font-extrabold text-slate-800">Manage Types</h1>
          <p class="text-sm text-slate-500">Create and maintain catalog book types.</p>
        </div>
        <AppButton @click="openCreate">Add type</AppButton>
      </div>
    </BaseCard>

    <BaseTable>
      <template #head>
        <th class="px-4 py-3 font-semibold">Name</th>
        <th class="px-4 py-3 font-semibold">Description</th>
        <th class="px-4 py-3 font-semibold">Actions</th>
      </template>

      <template #body>
        <tr v-for="type in types" :key="type.id" class="border-t border-sky-50">
          <td class="px-4 py-3">
            <p class="font-semibold text-slate-800">{{ type.name }}</p>
          </td>
          <td class="px-4 py-3 text-sm text-slate-600">{{ type.description || 'N/A' }}</td>
          <td class="px-4 py-3">
            <div class="flex gap-2">
              <AdminEditButton aria-label="Edit type" @click="openEdit(type)" />
              <AdminDeleteButton aria-label="Delete type" @click="removeType(type.id)" />
            </div>
          </td>
        </tr>
      </template>
    </BaseTable>

    <BasePagination :pagination="pagination" @change="fetchTypes" />

    <BaseModal
      :open="modalOpen"
      :title="editingId ? 'Edit type' : 'Create type'"
      @close="closeModal"
    >
      <form class="space-y-3" @submit.prevent="submitForm">
        <BaseInput v-model="form.name" label="Name" />
        <p v-if="fieldError('name')" class="-mt-2 text-xs font-medium text-red-600">
          {{ fieldError('name') }}
        </p>
        <BaseInput v-model="form.description" label="Description" />

        <div class="flex justify-end gap-2">
          <AppButton variant="secondary" type="button" @click="closeModal">Cancel</AppButton>
          <AppButton type="submit">{{ editingId ? 'Save changes' : 'Create type' }}</AppButton>
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
const types = ref([])
const pagination = ref({ current_page: 1, last_page: 1, per_page: 20, total: 0 })
const modalOpen = ref(false)
const editingId = ref(null)
const validationErrors = ref({})

const form = reactive({
  name: '',
  description: '',
})

function fieldError(fieldName) {
  const errors = validationErrors.value?.[fieldName]
  if (!Array.isArray(errors) || errors.length === 0) {
    return null
  }

  return errors[0]
}

function resetForm() {
  Object.assign(form, {
    name: '',
    description: '',
  })
  validationErrors.value = {}
}

async function fetchTypes(page = 1) {
  const { data } = await http.get('/admin/genres', { params: { page, per_page: 20 } })
  types.value = data.data
  pagination.value = data.meta?.pagination ?? pagination.value
}

function openCreate() {
  editingId.value = null
  resetForm()
  modalOpen.value = true
}

function openEdit(type) {
  editingId.value = type.id
  validationErrors.value = {}
  Object.assign(form, {
    name: type.name,
    description: type.description ?? '',
  })
  modalOpen.value = true
}

function closeModal() {
  modalOpen.value = false
  validationErrors.value = {}
}

async function submitForm() {
  try {
    validationErrors.value = {}

    if (editingId.value) {
      await http.patch(`/admin/genres/${editingId.value}`, form)
      uiStore.pushToast('Type updated.', 'success')
    } else {
      await http.post('/admin/genres', form)
      uiStore.pushToast('Type created.', 'success')
    }

    closeModal()
    await fetchTypes(pagination.value.current_page)
  } catch (error) {
    validationErrors.value = error.validationErrors ?? {}
    const message = error?.response?.data?.message ?? 'Unable to save this type.'
    uiStore.pushToast(message, 'error')
  }
}

async function removeType(typeId) {
  const confirmed = window.confirm('Delete this type permanently?')
  if (!confirmed) {
    return
  }

  try {
    await http.delete(`/admin/genres/${typeId}`)
    await fetchTypes(pagination.value.current_page)
    uiStore.pushToast('Type deleted.', 'success')
  } catch (error) {
    const message = error?.response?.data?.message ?? 'Unable to delete this type.'
    uiStore.pushToast(message, 'error')
  }
}

onMounted(fetchTypes)
</script>
