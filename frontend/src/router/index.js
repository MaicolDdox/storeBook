import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import AuthLayout from '@/layouts/AuthLayout.vue'
import ClientLayout from '@/layouts/ClientLayout.vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import LoginPage from '@/modules/shared/pages/LoginPage.vue'
import RegisterPage from '@/modules/shared/pages/RegisterPage.vue'
import CatalogPage from '@/modules/client/pages/CatalogPage.vue'
import BookDetailPage from '@/modules/client/pages/BookDetailPage.vue'
import CartPage from '@/modules/client/pages/CartPage.vue'
import CheckoutPage from '@/modules/client/pages/CheckoutPage.vue'
import OrdersPage from '@/modules/client/pages/OrdersPage.vue'
import OrderDetailPage from '@/modules/client/pages/OrderDetailPage.vue'
import AdminDashboardPage from '@/modules/admin/pages/AdminDashboardPage.vue'
import AdminBooksPage from '@/modules/admin/pages/AdminBooksPage.vue'
import AdminTypesPage from '@/modules/admin/pages/AdminTypesPage.vue'
import AdminCategoriesPage from '@/modules/admin/pages/AdminCategoriesPage.vue'
import AdminOrdersPage from '@/modules/admin/pages/AdminOrdersPage.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/app/catalog',
    },
    {
      path: '/',
      component: AuthLayout,
      children: [
        { path: 'login', name: 'login', component: LoginPage, meta: { guestOnly: true } },
        { path: 'register', name: 'register', component: RegisterPage, meta: { guestOnly: true } },
      ],
    },
    {
      path: '/app',
      component: ClientLayout,
      meta: { requiresAuth: true },
      children: [
        { path: 'catalog', name: 'catalog', component: CatalogPage },
        { path: 'books/:id', name: 'book-detail', component: BookDetailPage, props: true },
        { path: 'cart', name: 'cart', component: CartPage },
        { path: 'checkout', name: 'checkout', component: CheckoutPage },
        { path: 'orders', name: 'orders', component: OrdersPage },
        { path: 'orders/:id', name: 'order-detail', component: OrderDetailPage, props: true },
      ],
    },
    {
      path: '/admin',
      component: AdminLayout,
      meta: { requiresAuth: true, requiresAdmin: true },
      children: [
        { path: 'dashboard', name: 'admin-dashboard', component: AdminDashboardPage },
        { path: 'types', name: 'admin-types', component: AdminTypesPage },
        { path: 'books', name: 'admin-books', component: AdminBooksPage },
        { path: 'categories', name: 'admin-categories', component: AdminCategoriesPage },
        { path: 'orders', name: 'admin-orders', component: AdminOrdersPage },
      ],
    },
  ],
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore()
  await authStore.bootstrap()

  if (to.meta.requiresAuth && !authStore.token) {
    return { name: 'login' }
  }

  if (to.meta.requiresAdmin && !authStore.isAdmin) {
    return { name: 'catalog' }
  }

  if (to.meta.guestOnly && authStore.token) {
    return authStore.isAdmin ? { name: 'admin-dashboard' } : { name: 'catalog' }
  }

  return true
})

export default router
