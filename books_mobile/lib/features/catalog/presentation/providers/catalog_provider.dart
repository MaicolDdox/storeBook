import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/utils/resolve_book_image_url.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../shared/models/book_model.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../shared/models/genre_model.dart';

class CatalogState {
  const CatalogState({
    this.books = const [],
    this.categories = const [],
    this.genres = const [],
    this.search = '',
    this.selectedCategoryId,
    this.selectedGenreId,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<BookModel> books;
  final List<CategoryModel> categories;
  final List<GenreModel> genres;
  final String search;
  final int? selectedCategoryId;
  final int? selectedGenreId;
  final bool isLoading;
  final String? errorMessage;

  CatalogState copyWith({
    List<BookModel>? books,
    List<CategoryModel>? categories,
    List<GenreModel>? genres,
    String? search,
    int? selectedCategoryId,
    int? selectedGenreId,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CatalogState(
      books: books ?? this.books,
      categories: categories ?? this.categories,
      genres: genres ?? this.genres,
      search: search ?? this.search,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedGenreId: selectedGenreId ?? this.selectedGenreId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CatalogController extends StateNotifier<CatalogState> {
  CatalogController(this._ref) : super(const CatalogState());

  final Ref _ref;
  bool _loggedFirstImageProbe = false;

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = _ref.read(catalogRepositoryProvider);
      final results = await Future.wait([
        repository.fetchBooks(),
        repository.fetchCategories(),
        repository.fetchGenres(),
      ]);

      state = state.copyWith(
        books: results[0] as List<BookModel>,
        categories: results[1] as List<CategoryModel>,
        genres: results[2] as List<GenreModel>,
        isLoading: false,
      );
      _debugProbeFirstImage(state.books);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  Future<void> searchBooks(String value) async {
    state = state.copyWith(search: value, isLoading: true, clearError: true);
    await _fetchBooks();
  }

  Future<void> setCategory(int? categoryId) async {
    state = state.copyWith(
      selectedCategoryId: categoryId,
      isLoading: true,
      clearError: true,
    );
    await _fetchBooks();
  }

  Future<void> setGenre(int? genreId) async {
    state = state.copyWith(
      selectedGenreId: genreId,
      isLoading: true,
      clearError: true,
    );
    await _fetchBooks();
  }

  Future<void> refreshBooks() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final books = await _ref
          .read(catalogRepositoryProvider)
          .fetchBooks(
            search: state.search,
            categoryId: state.selectedCategoryId,
            genreId: state.selectedGenreId,
          );

      state = state.copyWith(books: books, isLoading: false);
      _debugProbeFirstImage(books);
    } on ApiException catch (exception) {
      state = state.copyWith(isLoading: false, errorMessage: exception.message);
    }
  }

  void _debugProbeFirstImage(List<BookModel> books) {
    if (!kDebugMode || _loggedFirstImageProbe || books.isEmpty) {
      return;
    }

    final firstUrl = resolveBookImageUrl(books.first);
    if (firstUrl == null) {
      debugPrint('[Catalog] First book has no image URL.');
      _loggedFirstImageProbe = true;
      return;
    }

    _loggedFirstImageProbe = true;
    debugPrint('[Catalog] First book image URL: $firstUrl');
    unawaited(_logImageResponseStatus(firstUrl));
  }

  Future<void> _logImageResponseStatus(String url) async {
    try {
      final response = await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
          followRedirects: true,
          validateStatus: (_) => true,
        ),
      ).head(url);
      debugPrint('[Catalog] First image HTTP status: ${response.statusCode}');
    } catch (error) {
      debugPrint('[Catalog] First image request failed: $error');
    }
  }
}

final catalogControllerProvider =
    StateNotifierProvider<CatalogController, CatalogState>((ref) {
      return CatalogController(ref);
    });

final bookDetailProvider = FutureProvider.family<BookModel, int>((ref, bookId) {
  return ref.read(catalogRepositoryProvider).fetchBook(bookId);
});
