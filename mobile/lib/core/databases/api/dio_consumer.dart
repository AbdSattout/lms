import 'package:dio/dio.dart';
import 'package:lms/core/databases/api/api_consumer.dart';
import 'package:lms/core/databases/api/end_points.dart';
import 'package:lms/core/errors/exceptions.dart';

import '../../../features/auth/data/datasources/auth_local_datasource.dart';
class DioConsumer extends ApiConsumer {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;

  void Function({required bool banned})? onAuthInvalidated;
  bool _authInvalidatedNotified = false;

  DioConsumer({
    required this.dio,
    required this.authLocalDataSource,
    this.onAuthInvalidated,
  }) {
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
          } catch (_) {}

          handler.next(options);
        },
        onResponse: (response, handler) {
          final status = response.statusCode ?? 0;
          if (status >= 200 &&
              status < 400 &&
              response.requestOptions.headers['Authorization'] != null) {
            _authInvalidatedNotified = false;
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          final response = error.response;
          final status = response?.statusCode;
          final sentToken =
              error.requestOptions.headers['Authorization'] != null;
          final banned = _isUserBanned(response?.data);

          if (sentToken && (status == 401 || (status == 403 && banned))) {
            if (_authInvalidatedNotified) {
              handler.next(error);
              return;
            }
            _authInvalidatedNotified = true;
            try {
              await authLocalDataSource.cache.removeData(
                key: authLocalDataSource.key,
              );
            } catch (_) {}
            onAuthInvalidated?.call(banned: banned);
          }
          handler.next(error);
        },
      ),
    );
  }

  bool _isUserBanned(Object? data) {
    if (data is Map) {
      final code = data['code'];
      if (code?.toString() == 'USER_BANNED') return true;
      final text = data['error']?.toString() ?? data['message']?.toString() ?? '';
      return text.contains('User is banned');
    }
    return data?.toString().contains('User is banned') ?? false;
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
      EndPoints.googleLogin,
      EndPoints.requestEmailOtp,
      EndPoints.verifyEmailOtp,
    ].any((authPath) => path == authPath || path.endsWith(authPath));
  }
}
