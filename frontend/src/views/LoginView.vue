<template>
  <div class="min-h-screen grid place-items-center bg-gradient-to-br from-slate-50 to-sky-50">
    <div class="w-full max-w-md bg-white/90 backdrop-blur rounded-2xl shadow-xl p-8 border border-slate-100">
      <div class="text-center mb-6">
        <h1 class="text-2xl font-semibold text-slate-800">Iniciar sesión</h1>
        <p class="text-sm text-slate-500 mt-1">Accede con tu correo y contraseña</p>
      </div>

      <form @submit.prevent="onSubmit" class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Correo</label>
          <input v-model="email" type="email" required
                 class="w-full rounded-xl border border-slate-200 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500 focus:border-sky-500"
                 placeholder="demo@demo.com" />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-700 mb-1">Contraseña</label>
          <input v-model="password" type="password" required
                 class="w-full rounded-xl border border-slate-200 px-4 py-2.5 outline-none focus:ring-2 focus:ring-sky-500 focus:border-sky-500"
                 placeholder="•••••••" />
        </div>

        <p v-if="error" class="text-sm text-rose-600">{{ error }}</p>

        <button :disabled="loading"
                class="w-full rounded-xl bg-sky-600 hover:bg-sky-700 disabled:opacity-60 text-white font-semibold py-2.5 transition">
          {{ loading ? 'Entrando…' : 'Entrar' }}
        </button>
      </form>

      <p class="text-center text-sm text-slate-500 mt-6">
        ¿No tienes cuenta?
        <router-link class="text-sky-700 hover:underline" to="/register">Crear cuenta</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';

const auth = useAuthStore();
const router = useRouter();

const email = ref('');
const password = ref('');
const loading = ref(false);
const error = ref('');

const onSubmit = async () => {
  error.value = '';
  loading.value = true;
  const { ok, message } = await auth.login(email.value, password.value);
  loading.value = false;

  if (ok) router.push('/');
  else error.value = message || 'Credenciales inválidas';
};
</script>
