import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { http, setupHttpInterceptors } from './services/http'
import { useAuthStore } from './stores/auth'
import { useUiStore } from './stores/ui'
import './assets/main.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

const authStore = useAuthStore(pinia)
const uiStore = useUiStore(pinia)

setupHttpInterceptors({ authStore, uiStore, router })

app.provide('http', http)
app.mount('#app')
