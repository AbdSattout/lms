import 'package:dio/dio.dart';
import 'package:lms/core/databases/api/api_consumer.dart';
import 'package:lms/core/databases/api/end_points.dart';
import 'package:lms/core/errors/exceptions.dart';

import '../../../features/auth/data/datasources/auth_local_datasource.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;
  final AuthLocalDataSource authLocalDataSource;
  DioConsumer({required this.dio,required this.authLocalDataSource}) {
    dio.options.baseUrl = EndPoints.baseUrl;
    dio.options.baseUrl = EndPoints.baseUrl;

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          print("INTERCEPTOR RUNNING");

          if (options.path == EndPoints.login ||
              options.path.endsWith(EndPoints.login)) {
            print("LOGIN REQUEST -> SKIP AUTH HEADER");
            handler.next(options);
            return;
          }

          try {
            final auth = await authLocalDataSource.getCachedAuthData();

            print("TOKEN FOUND:");
            print(auth.token);

            options.headers["Authorization"] =
            "Bearer ${auth.token}";
          } catch (e) {
            print("TOKEN ERROR:");
            print(e);
          }

          handler.next(options);
        },
      ),
    );
  }

//!POST
  @override
  Future post(String path,
      {dynamic data,
        Map<String, dynamic>? queryParameters,
        bool isFormData = false}) async {
    try {
      var res = await dio.post(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      // TEMPORARY DIAGNOSTIC — remove once the issue is traced.
      print('DioException on $path -> type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response?.statusCode} ${e.response?.data}');
      handleDioException(e);
    }
  }

//!GET
  @override
  Future get(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      var res =
      await dio.get(path, data: data, queryParameters: queryParameters);
      return res.data;
    } on DioException catch (e) {
      print('DioException on $path -> type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response?.statusCode} ${e.response?.data}');
      handleDioException(e);
    }
  }

  @override
  Future put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool isFormData = false,
      }) async {

    try {

      var res = await dio.put(
        path,
        data: isFormData
            ? FormData.fromMap(data)
            : data,
        queryParameters: queryParameters,
      );

      return res.data;

    } on DioException catch (e) {
      print('DioException on $path -> type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response?.statusCode} ${e.response?.data}');
      handleDioException(e);
    }
  }
//!DELETE
  @override
  Future delete(String path,
      {Object? data, Map<String, dynamic>? queryParameters}) async {
    try {
      var res = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      print('DioException on $path -> type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response?.statusCode} ${e.response?.data}');
      handleDioException(e);
    }
  }

//!PATCH
  @override
  Future patch(String path,
      {dynamic data,
        Map<String, dynamic>? queryParameters,
        bool isFormData = false}) async {
    try {
      var res = await dio.patch(
        path,
        data: isFormData ? FormData.fromMap(data) : data,
        queryParameters: queryParameters,
      );
      return res.data;
    } on DioException catch (e) {
      print('DioException on $path -> type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response?.statusCode} ${e.response?.data}');
      handleDioException(e);
    }
  }
}