import { defineStore } from 'pinia'
import { http } from '@/services/http'

function emptyCart() {
  return {
    id: null,
    status: 'active',
    item_count: 0,
    subtotal_cents: 0,
    items: [],
  }
}

export const useCartStore = defineStore('cart', {
  state: () => ({
    cart: emptyCart(),
  }),

  getters: {
    subtotal: (state) => (state.cart.subtotal_cents / 100).toFixed(2),
    hasItems: (state) => state.cart.items.length > 0,
  },

  actions: {
    async fetchCart() {
      const { data } = await http.get('/cart')
      this.cart = data.data
    },

    async addItem(bookId, quantity = 1) {
      const { data } = await http.post('/cart/items', {
        book_id: bookId,
        quantity,
      })
      this.cart = data.data
    },

    async updateItem(itemId, quantity) {
      const { data } = await http.patch(`/cart/items/${itemId}`, { quantity })
      this.cart = data.data
    },

    async removeItem(itemId) {
      const { data } = await http.delete(`/cart/items/${itemId}`)
      this.cart = data.data
    },

    async clearCart() {
      const { data } = await http.delete('/cart/items')
      this.cart = data.data
    },
  },
})
