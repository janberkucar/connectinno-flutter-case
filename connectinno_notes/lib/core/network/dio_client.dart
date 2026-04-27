import 'package:connectinno_notes/core/network/api_constants.dart';
import 'package:connectinno_notes/core/network/interceptors/auth_interceptor.dart';
import 'package:connectinno_notes/core/network/interceptors/error_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Configured [Dio] for the app — base URL, timeouts, interceptors.
class DioClient {
  DioClient({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;
  Dio? _dio;

  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: <String, dynamic>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Only 2xx are successful — 4xx/5xx surface as [DioException] for handling.
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );
    d.interceptors.addAll([
      AuthInterceptor(secureStorage: _secureStorage),
      ErrorInterceptor(),
    ]);
    return d;
  }
}
