class ApiException implements Exception {
  final int? code;
  final String error;
  final String message;

  ApiException({this.code, required this.error, required this.message});

  @override
  String toString() =>
      'ApiException(code: $code, error: $error, message: $message)';
}
