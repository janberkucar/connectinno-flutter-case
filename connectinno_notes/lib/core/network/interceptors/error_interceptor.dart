import 'package:connectinno_notes/core/failures/app_failure.dart';
import 'package:dio/dio.dart';

/// Maps HTTP errors to [DioException] with normalized [DioException.error] for callers.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = _messageFor(err);
    final failure = AppFailure(message, code: err.response?.statusCode?.toString());
    final next = err.copyWith(error: failure);
    handler.next(next);
  }

  String _messageFor(DioException err) {
    final data = err.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check your connection.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Is the API running?';
      default:
        return err.message ?? 'Network error';
    }
  }
}
