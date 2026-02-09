import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import AuthLayout from '@/layouts/AuthLayout.vue'
import ClientLayout from '@/layouts/ClientLayout.vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import HomePage from '@/modules/client/pages/HomePage.vue'
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
      component: AuthLayout,
      children: [
        { path: 'login', name: 'login', component: LoginPage, meta: { guestOnly: true } },
        { path: 'register', name: 'register', component: RegisterPage, meta: { guestOnly: true } },
      ],
    },
    {
      path: '/',
      component: ClientLayout,
      children: [
        { path: '', name: 'home', component: HomePage },
        { path: 'catalog', name: 'catalog', component: CatalogPage },
        { path: 'books/:id', name: 'book-detail', component: BookDetailPage, props: true },
        {
          path: 'cart',
          name: 'cart',
          component: CartPage,
          meta: { requiresAuth: true },
        },
        {
          path: 'checkout',
          name: 'checkout',
          component: CheckoutPage,
          meta: { requiresAuth: true },
        },
        {
          path: 'orders',
          name: 'orders',
          component: OrdersPage,
          meta: { requiresAuth: true },
        },
        {
          path: 'orders/:id',
          name: 'order-detail',
          component: OrderDetailPage,
          props: true,
          meta: { requiresAuth: true },
        },
      ],
    },
    {
      path: '/admin',
      component: AdminLayout,
      meta: { requiresAuth: true, requiresAdmin: true },
      children: [
        { path: '', redirect: { name: 'admin-dashboard' } },
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
    return { name: 'login', query: { returnUrl: to.fullPath } }
  }

  if (to.meta.requiresAdmin && !authStore.isAdmin) {
    return { name: 'home' }
  }

  if (to.meta.guestOnly && authStore.token) {
    const returnUrl = to.query.returnUrl
    if (returnUrl && !returnUrl.startsWith('/login') && !returnUrl.startsWith('/register')) {
      return returnUrl
    }
    return authStore.isAdmin ? { name: 'admin-dashboard' } : { name: 'home' }
  }

  return true
})

export default router
