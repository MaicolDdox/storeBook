class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.validationErrors});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? validationErrors;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}
