import { http } from '@/services/http'

/**
 * Single source of truth for catalog API calls.
 * Used by useCatalogStore.
 */

export const catalogApi = {
  getBooks(params) {
    return http.get('/catalog/books', { params })
  },

  getBook(bookId) {
    return http.get(`/catalog/books/${bookId}`)
  },

  getCategories(params = {}) {
    return http.get('/catalog/categories', { params })
  },

  getGenres(params = {}) {
    return http.get('/catalog/genres', { params })
  },
}
