import { defineStore } from 'pinia'

export const useUiStore = defineStore('ui', {
  state: () => ({
    pendingRequests: 0,
    toasts: [],
  }),

  getters: {
    isLoading: (state) => state.pendingRequests > 0,
  },

  actions: {
    incrementPending() {
      this.pendingRequests += 1
    },

    decrementPending() {
      this.pendingRequests = Math.max(0, this.pendingRequests - 1)
    },

    pushToast(message, type = 'info') {
      const toast = {
        id: Date.now() + Math.floor(Math.random() * 1000),
        message,
        type,
      }
      this.toasts.push(toast)
      setTimeout(() => this.removeToast(toast.id), 3500)
    },

    removeToast(id) {
      this.toasts = this.toasts.filter((toast) => toast.id !== id)
    },
  },
})
