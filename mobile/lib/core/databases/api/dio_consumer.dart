import 'package:dio/dio.dart';
import 'package:lms/core/databases/api/api_consumer.dart';
import 'package:lms/core/databases/api/end_points.dart';
import 'package:lms/core/errors/exceptions.dart';

import '../../../features/auth/data/datasources/auth_local_datasource.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  DioConsumer({required this.dio, required this.authLocalDataSource}) {
    dio.options.baseUrl = EndPoints.baseUrl;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_isAuthFreePath(options.path)) {
            handler.next(options);
            return;
          }

          try {
            final auth = await authLocalDataSource.getCachedAuthData();
            options.headers['Authorization'] = 'Bearer ${auth.token}';
          } catch (_) {
            // Unauthenticated requests outside the auth flow continue without a token.
          }

          handler.next(options);
        },
      ),
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final res = await dio.post(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final res = await dio.put(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );

      return res.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
  }) async {
    try {
      final res = await dio.patch(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  bool _isAuthFreePath(String path) {
    return const [
      EndPoints.login,
      EndPoints.requestEmailOtp,
      EndPoints.verifyEmailOtp,
    ].any((authPath) => path == authPath || path.endsWith(authPath));
  }
}
