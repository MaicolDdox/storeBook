<template>
  <div class="space-y-4">
    <BaseCard>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-2xl font-extrabold text-slate-800">Your Cart</h1>
          <p class="text-sm text-slate-500">Review and update your selected books.</p>
        </div>
        <BaseButton
          variant="secondary"
          :disabled="!cartStore.hasItems"
          @click="cartStore.clearCart()"
        >
          Clear cart
        </BaseButton>
      </div>
    </BaseCard>

    <BaseCard v-for="item in cartStore.cart.items" :key="item.id">
      <div class="grid gap-3 sm:grid-cols-[1fr_auto_auto] sm:items-center">
        <div>
          <h3 class="text-lg font-bold text-slate-800">{{ item.book?.title }}</h3>
          <p class="text-sm text-slate-500">{{ item.book?.author }}</p>
          <p class="text-sm font-semibold text-brightBlue">
            ${{ (item.total_price_cents / 100).toFixed(2) }}
          </p>
        </div>

        <div class="flex items-center gap-2">
          <button
            class="rounded-lg border border-sky-200 px-3 py-1"
            @click="changeQty(item, item.quantity - 1)"
          >
            -
          </button>
          <span class="w-6 text-center text-sm font-semibold">{{ item.quantity }}</span>
          <button
            class="rounded-lg border border-sky-200 px-3 py-1"
            @click="changeQty(item, item.quantity + 1)"
          >
            +
          </button>
        </div>

        <BaseButton variant="danger" @click="remove(item.id)">Remove</BaseButton>
      </div>
    </BaseCard>

    <BaseCard v-if="!cartStore.hasItems">
      <p class="text-sm text-slate-600">Your cart is currently empty.</p>
    </BaseCard>

    <BaseCard v-else>
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <p class="text-sm text-slate-500">Subtotal</p>
          <p class="text-2xl font-extrabold text-brightBlue">${{ cartStore.subtotal }}</p>
        </div>
        <router-link to="/app/checkout">
          <BaseButton>Go to checkout</BaseButton>
        </router-link>
      </div>
    </BaseCard>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import BaseCard from '@/components/base/BaseCard.vue'
import BaseButton from '@/components/base/BaseButton.vue'
import { useCartStore } from '@/stores/cart'
import { useUiStore } from '@/stores/ui'

const cartStore = useCartStore()
const uiStore = useUiStore()

async function changeQty(item, nextValue) {
  if (nextValue < 1) {
    return
  }

  try {
    await cartStore.updateItem(item.id, nextValue)
  } catch {
    uiStore.pushToast('Unable to update cart quantity.', 'error')
  }
}

async function remove(itemId) {
  try {
    await cartStore.removeItem(itemId)
    uiStore.pushToast('Item removed from cart.', 'success')
  } catch {
    uiStore.pushToast('Unable to remove this item.', 'error')
  }
}

onMounted(async () => {
  await cartStore.fetchCart()
})
</script>
