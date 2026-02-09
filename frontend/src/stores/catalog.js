import { defineStore } from 'pinia'
import { catalogApi } from '@/services/catalog.api'

function defaultPagination() {
  return {
    current_page: 1,
    last_page: 1,
    per_page: 12,
    total: 0,
  }
}

export const useCatalogStore = defineStore('catalog', {
  state: () => ({
    books: [],
    currentBook: null,
    categories: [],
    genres: [],
    pagination: defaultPagination(),
    loading: false,
    error: null,
    filters: {
      search: '',
      category_id: null,
      genre_id: null,
      sort: 'newest',
      page: 1,
      per_page: 12,
    },
  }),

  actions: {
    async fetchBooks(overrides = {}) {
      this.loading = true
      this.error = null
      try {
        const params = { ...this.filters, ...overrides }
        const { data } = await catalogApi.getBooks(params)
        this.books = data.data
        this.pagination = data.meta?.pagination ?? defaultPagination()
      } catch (err) {
        this.error = err.response?.data?.message ?? 'Failed to load books'
        throw err
      } finally {
        this.loading = false
      }
    },

    async fetchBook(bookId) {
      this.loading = true
      this.error = null
      try {
        const { data } = await catalogApi.getBook(bookId)
        this.currentBook = data.data
        return this.currentBook
      } catch (err) {
        this.error = err.response?.data?.message ?? 'Failed to load book'
        throw err
      } finally {
        this.loading = false
      }
    },

    async fetchCategories() {
      const { data } = await catalogApi.getCategories({ per_page: 50 })
      this.categories = data.data
    },

    async fetchGenres() {
      const { data } = await catalogApi.getGenres({ per_page: 50 })
      this.genres = data.data
    },

    setPage(page) {
      this.filters.page = page
    },

    resetFilters() {
      this.filters = {
        search: '',
        category_id: null,
        genre_id: null,
        sort: 'newest',
        page: 1,
        per_page: 12,
      }
    },
  },
})
