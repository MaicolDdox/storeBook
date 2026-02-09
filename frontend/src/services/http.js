import axios from 'axios'

const apiHost = import.meta.env.VITE_API_BASE_URL ?? 'http://127.0.0.1:8000'
const normalizedHost = apiHost.endsWith('/') ? apiHost.slice(0, -1) : apiHost

export const http = axios.create({
  baseURL: `${normalizedHost}/api`,
  headers: {
    Accept: 'application/json',
  },
})

let isConfigured = false

export function setupHttpInterceptors({ authStore, uiStore, router }) {
  if (isConfigured) {
    return
  }

  http.interceptors.request.use(
    (config) => {
      uiStore.incrementPending()
      if (authStore.token) {
        config.headers.Authorization = `Bearer ${authStore.token}`
      }
      return config
    },
    (error) => {
      uiStore.decrementPending()
      return Promise.reject(error)
    },
  )

  http.interceptors.response.use(
    (response) => {
      uiStore.decrementPending()
      return response
    },
    async (error) => {
      uiStore.decrementPending()
      const status = error.response?.status
      const path = error.config?.url ?? ''

      if (status === 401 && !path.includes('/auth/login') && !path.includes('/auth/register')) {
        authStore.clearSession()
        uiStore.pushToast('Your session has expired. Please sign in again.', 'error')
        await router.push({ name: 'login' })
      }

      if (status === 403) {
        uiStore.pushToast('You are not authorized to access this resource.', 'error')
      }

      if (status === 422) {
        error.validationErrors = error.response?.data?.errors ?? {}
      }

      return Promise.reject(error)
    },
  )

  isConfigured = true
}
