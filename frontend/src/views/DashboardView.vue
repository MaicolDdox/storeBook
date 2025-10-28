<template>
  <div class="min-h-screen bg-slate-50">
    <header class="bg-white border-b border-slate-200">
      <div class="max-w-6xl mx-auto px-6 py-4 flex items-center justify-between">
        <h2 class="text-xl font-semibold text-slate-800">Panel</h2>
        <div class="flex items-center gap-3">
          <span class="text-slate-600">Hola, {{ auth.user?.name }}</span>
          <button @click="logout"
                  class="rounded-lg bg-slate-800 hover:bg-slate-900 text-white px-4 py-2 text-sm">
            Cerrar sesión
          </button>
        </div>
      </div>
    </header>

    <main class="max-w-6xl mx-auto px-6 py-10">
      <div class="grid gap-6">
        <div class="rounded-2xl bg-white border border-slate-200 shadow-sm p-6">
          <h3 class="text-lg font-semibold text-slate-800 mb-2">¡Autenticación lista!</h3>
          <p class="text-slate-600">Ya puedes consumir tus endpoints protegidos con <code class="px-1 rounded bg-slate-100">auth:sanctum</code>.</p>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useAuthStore } from '../stores/auth';
const auth = useAuthStore();

const logout = async () => {
  await auth.logout();
  window.location.href = '/login';
};
</script>
