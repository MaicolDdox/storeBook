import { defineStore } from 'pinia'
import { http } from '@/services/http'

const TOKEN_KEY = 'storebook_token'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem(TOKEN_KEY),
    user: null,
    bootstrapped: false,
  }),

  getters: {
    isAuthenticated: (state) => Boolean(state.token && state.user),
    roleNames: (state) => state.user?.roles ?? [],
    isAdmin: (state) => (state.user?.roles ?? []).includes('admin'),
  },

  actions: {
    async bootstrap() {
      if (this.bootstrapped) {
        return
      }

      if (!this.token) {
        this.bootstrapped = true
        return
      }

      try {
        const { data } = await http.get('/auth/me')
        this.user = data.data
      } catch {
        this.clearSession()
      } finally {
        this.bootstrapped = true
      }
    },

    async login(payload) {
      const { data } = await http.post('/auth/login', payload)
      this.token = data.data.token
      this.user = data.data.user
      this.persistToken()
      return data
    },

    async register(payload) {
      const { data } = await http.post('/auth/register', payload)
      this.token = data.data.token
      this.user = data.data.user
      this.persistToken()
      return data
    },

    async logout() {
      try {
        await http.post('/auth/logout')
      } finally {
        this.clearSession()
      }
    },

    clearSession() {
      this.token = null
      this.user = null
      localStorage.removeItem(TOKEN_KEY)
    },

    persistToken() {
      if (!this.token) {
        localStorage.removeItem(TOKEN_KEY)
        return
      }
      localStorage.setItem(TOKEN_KEY, this.token)
    },
  },
})
