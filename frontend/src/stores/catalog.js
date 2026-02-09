import { defineStore } from 'pinia'
import { http } from '@/services/http'

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
    async fetchBooks() {
      const { data } = await http.get('/catalog/books', {
        params: this.filters,
      })

      this.books = data.data
      this.pagination = data.meta?.pagination ?? defaultPagination()
    },

    async fetchBook(bookId) {
      const { data } = await http.get(`/catalog/books/${bookId}`)
      this.currentBook = data.data
      return this.currentBook
    },

    async fetchCategories() {
      const { data } = await http.get('/catalog/categories', {
        params: { per_page: 50 },
      })
      this.categories = data.data
    },

    async fetchGenres() {
      const { data } = await http.get('/catalog/genres', {
        params: { per_page: 50 },
      })
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
