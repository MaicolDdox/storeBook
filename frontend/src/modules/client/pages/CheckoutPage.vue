<template>
  <div class="grid gap-4 lg:grid-cols-[1fr_340px]">
    <div class="space-y-4">
      <BaseCard>
        <h1 class="text-2xl font-extrabold text-slate-800">Checkout</h1>
        <p class="text-sm text-slate-500">Select a shipping address and payment method.</p>
      </BaseCard>

      <BaseCard>
        <div class="mb-3 flex items-center justify-between">
          <h2 class="text-lg font-bold text-slate-800">Saved addresses</h2>
          <AppButton variant="secondary" @click="showAddressForm = !showAddressForm">
            {{ showAddressForm ? 'Hide form' : 'Add address' }}
          </AppButton>
        </div>

        <div class="space-y-2">
          <label
            v-for="address in ordersStore.addresses"
            :key="address.id"
            class="flex cursor-pointer items-start gap-3 rounded-xl border border-sky-100 p-3"
          >
            <input v-model.number="selectedAddressId" type="radio" :value="address.id" />
            <div class="text-sm text-slate-700">
              <p class="font-semibold">{{ address.recipient_name }}</p>
              <p>{{ address.line1 }}, {{ address.city }}, {{ address.postal_code }}</p>
              <p>{{ address.country }}</p>
            </div>
          </label>
        </div>

        <form
          v-if="showAddressForm"
          class="mt-4 grid gap-3 sm:grid-cols-2"
          @submit.prevent="createAddress"
        >
          <BaseInput v-model="addressForm.recipient_name" label="Recipient" />
          <BaseInput v-model="addressForm.line1" label="Address line 1" />
          <BaseInput v-model="addressForm.city" label="City" />
          <BaseInput v-model="addressForm.state" label="State" />
          <BaseInput v-model="addressForm.postal_code" label="Postal code" />
          <BaseInput v-model="addressForm.country" label="Country code" />
          <div class="sm:col-span-2">
            <AppButton type="submit">Save address</AppButton>
          </div>
        </form>
      </BaseCard>

      <BaseCard>
        <h2 class="mb-2 text-lg font-bold text-slate-800">Payment method</h2>
        <label class="flex items-center gap-2 text-sm">
          <input v-model="paymentMethod" type="radio" value="cash_on_delivery" />
          Cash on delivery
        </label>
        <label class="mt-2 flex items-center gap-2 text-sm">
          <input v-model="paymentMethod" type="radio" value="bank_transfer" />
          Bank transfer
        </label>
        <label class="mt-2 flex items-center gap-2 text-sm">
          <input v-model="paymentMethod" type="radio" value="card" />
          Card (mocked)
        </label>
      </BaseCard>
    </div>

    <BaseCard>
      <h2 class="mb-3 text-lg font-bold text-slate-800">Order summary</h2>
      <div class="space-y-2 text-sm text-slate-600">
        <div v-for="item in cartStore.cart.items" :key="item.id" class="flex justify-between">
          <span>{{ item.book?.title }} x{{ item.quantity }}</span>
          <span>${{ (item.total_price_cents / 100).toFixed(2) }}</span>
        </div>
      </div>
      <div class="my-4 border-t border-sky-100 pt-3">
        <p class="text-sm text-slate-500">Subtotal</p>
        <p class="text-2xl font-extrabold text-brightBlue">${{ cartStore.subtotal }}</p>
      </div>
      <AppButton class="w-full" :disabled="!canCheckout" @click="placeOrder"
        >Place order</AppButton
      >
    </BaseCard>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import BaseCard from '@/components/base/BaseCard.vue'
import AppButton from '@/components/ui/AppButton.vue'
import BaseInput from '@/components/base/BaseInput.vue'
import { useOrdersStore } from '@/stores/orders'
import { useCartStore } from '@/stores/cart'
import { useUiStore } from '@/stores/ui'

const router = useRouter()
const ordersStore = useOrdersStore()
const cartStore = useCartStore()
const uiStore = useUiStore()

const showAddressForm = ref(false)
const selectedAddressId = ref(null)
const paymentMethod = ref('cash_on_delivery')

const addressForm = reactive({
  type: 'shipping',
  recipient_name: '',
  line1: '',
  line2: '',
  city: '',
  state: '',
  postal_code: '',
  country: 'US',
  phone: '',
  is_default: true,
})

const canCheckout = computed(() => selectedAddressId.value && cartStore.hasItems)

async function createAddress() {
  try {
    const created = await ordersStore.createAddress(addressForm)
    selectedAddressId.value = created.id
    showAddressForm.value = false
    uiStore.pushToast('Address added.', 'success')
  } catch {
    uiStore.pushToast('Unable to save address.', 'error')
  }
}

async function placeOrder() {
  if (!canCheckout.value) {
    uiStore.pushToast('Select an address before placing the order.', 'error')
    return
  }

  try {
    const order = await ordersStore.checkout({
      address_id: selectedAddressId.value,
      payment_method: paymentMethod.value,
    })
    await cartStore.fetchCart()
    uiStore.pushToast('Order placed successfully.', 'success')
    await router.push(`/orders/${order.id}`)
  } catch {
    uiStore.pushToast('Unable to place order.', 'error')
  }
}

onMounted(async () => {
  await Promise.all([ordersStore.fetchAddresses(), cartStore.fetchCart()])
  if (ordersStore.addresses.length > 0) {
    selectedAddressId.value = ordersStore.addresses[0].id
  }
})
</script>
