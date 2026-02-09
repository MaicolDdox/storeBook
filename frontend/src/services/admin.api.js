import { http } from '@/services/http'

export const adminApi = {
  getDashboard() {
    return http.get('/admin/dashboard')
  },

  getOrdersOverTime(range = '30d') {
    return http.get('/admin/metrics/orders-over-time', { params: { range } })
  },

  getTopCategories(range = '30d') {
    return http.get('/admin/metrics/top-categories', { params: { range } })
  },

  getOrderStatusDistribution(range = '30d') {
    return http.get('/admin/metrics/order-status-distribution', { params: { range } })
  },

  getRecentOrders() {
    return http.get('/admin/metrics/recent-orders')
  },

  getLowStock() {
    return http.get('/admin/metrics/low-stock')
  },
}
