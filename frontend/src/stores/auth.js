import { defineStore } from 'pinia'
import api from '../plugins/axios'

export const useAuthStore = defineStore('auth', {
  state: () => ({ user: null, loading: false }),

  actions: {
    // REGISTRO -> devuelve token; lo guardamos y ya quedas logueado
    async register(name, email, password) {
      this.loading = true
      try {
        const { data } = await api.post('/api/auth/register', { name, email, password })
        localStorage.setItem('token', data.token)
        api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`
        this.user = data.user
        return { ok: true }
      } catch (error) {
        const msg = error?.response?.data?.message || 'Error al registrar'
        return { ok: false, message: msg }
      } finally { this.loading = false }
    },

    // LOGIN -> guarda token y header
    async login(email, password) {
      this.loading = true
      try {
        const { data } = await api.post('/api/auth/login', { email, password, device: 'web' })
        localStorage.setItem('token', data.token)
        api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`
        this.user = data.user
        return { ok: true }
      } catch (error) {
        const msg = error?.response?.data?.message || 'Error al iniciar sesión'
        return { ok: false, message: msg }
      } finally { this.loading = false }
    },

    // CARGAR PERFIL (si hay token)
    async getUser() {
      try {
        const { data } = await api.get('/api/me')
        this.user = data
      } catch { this.user = null }
    },

    // LOGOUT -> revoca token en backend y limpia front
    async logout() {
      try { await api.post('/api/auth/logout') } catch {}
      localStorage.removeItem('token')
      delete api.defaults.headers.common['Authorization']
      this.user = null
    },
  },
})
