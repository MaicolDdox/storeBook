<template>
  <button
    v-bind="$attrs"
    :type="type"
    :disabled="disabled"
    :class="['base-button', `base-button--${normalizedVariant}`]"
  >
    <slot />
  </button>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  type: {
    type: String,
    default: 'button',
  },
  disabled: {
    type: Boolean,
    default: false,
  },
  variant: {
    type: String,
    default: 'primary',
  },
})

const normalizedVariant = computed(() => {
  if (props.variant === 'secondary' || props.variant === 'danger') {
    return props.variant
  }

  return 'primary'
})
</script>

<style scoped>
.base-button {
  align-items: center;
  border: 1px solid transparent;
  border-radius: 0.75rem;
  cursor: pointer;
  display: inline-flex;
  font-size: 0.875rem;
  font-weight: 700;
  gap: 0.5rem;
  justify-content: center;
  padding: 0.5rem 1rem;
  transition:
    background-color 0.2s ease,
    border-color 0.2s ease,
    color 0.2s ease,
    opacity 0.2s ease,
    transform 0.2s ease;
}

.base-button:focus-visible {
  outline: 2px solid rgba(0, 171, 228, 0.35);
  outline-offset: 2px;
}

.base-button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
  transform: none;
}

.base-button:not(:disabled):hover {
  transform: translateY(-1px);
}

.base-button--primary {
  background-color: var(--bright-blue);
  color: var(--white);
}

.base-button--primary:not(:disabled):hover {
  background-color: #0097c9;
}

.base-button--secondary {
  background-color: var(--white);
  border-color: var(--bright-blue);
  color: #075985;
}

.base-button--secondary:not(:disabled):hover {
  background-color: var(--light-blue);
}

.base-button--danger {
  background-color: #dc2626;
  color: var(--white);
}

.base-button--danger:not(:disabled):hover {
  background-color: #b91c1c;
}
</style>
