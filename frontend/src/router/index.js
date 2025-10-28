import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '../stores/auth';
import LoginView from '../views/LoginView.vue';
import RegisterView from '../views/RegisterView.vue';
import DashboardView from '../views/DashboardView.vue';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', name: 'dashboard', component: DashboardView, meta: { requiresAuth: true } },
    { path: '/login', name: 'login', component: LoginView },
    { path: '/register', name: 'register', component: RegisterView },
  ],
});

router.beforeEach(async (to) => {
  const auth = useAuthStore();
  if (!auth.user) await auth.getUser();

  if (to.meta.requiresAuth && !auth.user) return { name: 'login' };
  if ((to.name === 'login' || to.name === 'register') && auth.user) return { name: 'dashboard' };
});

export default router;
