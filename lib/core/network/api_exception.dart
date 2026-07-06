enum ApiExceptionType {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  tooManyRequests,
  server,
  request,
  timeout,
  network,
  invalidResponse,
}

// Normalized error object for the data layer. Services can throw one exception
// type, and cubits can map it into user-facing messages without inspecting HTTP.
class ApiException implements Exception {
  const ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
    this.cause,
  });

  factory ApiException.fromResponse({
    required int statusCode,
    required Object? data,
  }) {
    // Prefer a backend-provided message when available, but keep a predictable
    // fallback so UI code always has safe copy to show.
    return ApiException(
      type: _typeFromStatusCode(statusCode),
      message: _messageFromData(data) ?? _fallbackMessage(statusCode),
      statusCode: statusCode,
      data: data,
    );
  }

  factory ApiException.timeout({Object? cause}) {
    return ApiException(
      type: ApiExceptionType.timeout,
      message: 'The request timed out. Please try again.',
      cause: cause,
    );
  }

  factory ApiException.network({Object? cause}) {
    return ApiException(
      type: ApiExceptionType.network,
      message: 'Unable to connect to the server. Check your connection.',
      cause: cause,
    );
  }

  factory ApiException.invalidResponse({Object? cause}) {
    return ApiException(
      type: ApiExceptionType.invalidResponse,
      message: 'The server returned an invalid response.',
      cause: cause,
    );
  }

  final ApiExceptionType type;
  final String message;
  final int? statusCode;
  final Object? data;
  final Object? cause;

  // Auth flows often need to react to 401 and 403 the same way: clear or request
  // credentials instead of treating them as generic request failures.
  bool get isAuthenticationFailure =>
      type == ApiExceptionType.unauthorized ||
      type == ApiExceptionType.forbidden;

  @override
  String toString() {
    final status = statusCode == null ? '' : ' ($statusCode)';
    return 'ApiException$status: $message';
  }

  static ApiExceptionType _typeFromStatusCode(int statusCode) {
    return switch (statusCode) {
      400 => ApiExceptionType.badRequest,
      401 => ApiExceptionType.unauthorized,
      403 => ApiExceptionType.forbidden,
      404 => ApiExceptionType.notFound,
      409 => ApiExceptionType.conflict,
      422 => ApiExceptionType.validation,
      429 => ApiExceptionType.tooManyRequests,
      >= 500 => ApiExceptionType.server,
      _ => ApiExceptionType.request,
    };
  }

  static String? _messageFromData(Object? data) {
    if (data case {
      'message': final String message,
    } when message.trim().isNotEmpty) {
      return message.trim();
    }

    return null;
  }

  static String _fallbackMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'The request could not be processed.',
      401 => 'Please sign in to continue.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested resource was not found.',
      409 => 'The request conflicts with the current data.',
      422 => 'Some submitted data is not valid.',
      429 => 'Too many requests. Please try again later.',
      >= 500 => 'The server could not process the request.',
      _ => 'The request failed with status code $statusCode.',
    };
  }
}
