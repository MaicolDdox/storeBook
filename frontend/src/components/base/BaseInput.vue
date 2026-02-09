<template>
  <label class="block w-full">
    <span v-if="label" class="mb-1 block text-sm font-medium text-slate-700">
      {{ label }}
    </span>
    <input
      :type="type"
      :value="modelValue"
      :placeholder="placeholder"
      :disabled="disabled"
      class="w-full rounded-xl border border-sky-100 bg-white px-3 py-2 text-sm outline-none transition focus:border-brightBlue focus:ring-2 focus:ring-brightBlue/20"
      @input="$emit('update:modelValue', $event.target.value)"
    />
  </label>
</template>

<script setup>
defineProps({
  modelValue: {
    type: [String, Number],
    default: '',
  },
  label: {
    type: String,
    default: '',
  },
  placeholder: {
    type: String,
    default: '',
  },
  type: {
    type: String,
    default: 'text',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
})

defineEmits(['update:modelValue'])
</script>
