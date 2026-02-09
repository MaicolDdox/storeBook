import '../../../core/network/api_client.dart';
import '../../../shared/models/book_model.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/genre_model.dart';

class CatalogRepository {
  CatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BookModel>> fetchBooks({
    String? search,
    int? categoryId,
    int? genreId,
    int page = 1,
  }) async {
    final response = await _apiClient.get(
      '/catalog/books',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category_id': categoryId,
        if (genreId != null) 'genre_id': genreId,
        'page': page,
      },
    );

    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BookModel> fetchBook(int bookId) async {
    final response = await _apiClient.get('/catalog/books/$bookId');
    return BookModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _apiClient.get(
      '/catalog/categories',
      queryParameters: {'per_page': 100},
    );
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<GenreModel>> fetchGenres() async {
    final response = await _apiClient.get(
      '/catalog/genres',
      queryParameters: {'per_page': 100},
    );
    final items = response.data['data'] as List<dynamic>;
    return items
        .map((item) => GenreModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
