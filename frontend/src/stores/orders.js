import { defineStore } from 'pinia'
import { http } from '@/services/http'

function defaultPagination() {
  return {
    current_page: 1,
    last_page: 1,
    per_page: 15,
    total: 0,
  }
}

export const useOrdersStore = defineStore('orders', {
  state: () => ({
    orders: [],
    order: null,
    addresses: [],
    pagination: defaultPagination(),
  }),

  actions: {
    async fetchOrders(page = 1) {
      const { data } = await http.get('/orders', {
        params: { page, per_page: 15 },
      })
      this.orders = data.data
      this.pagination = data.meta?.pagination ?? defaultPagination()
    },

    async fetchOrder(orderId) {
      const { data } = await http.get(`/orders/${orderId}`)
      this.order = data.data
    },

    async fetchAddresses() {
      const { data } = await http.get('/addresses', {
        params: { per_page: 30 },
      })
      this.addresses = data.data
    },

    async createAddress(payload) {
      const { data } = await http.post('/addresses', payload)
      const createdAddress = data.data
      this.addresses = [createdAddress, ...this.addresses]
      return createdAddress
    },

    async checkout(payload) {
      const { data } = await http.post('/orders', payload)
      this.order = data.data
      return data.data
    },
  },
})
