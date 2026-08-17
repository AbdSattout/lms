import 'dart:convert';
import '../../../../core/databases/cache/cache_helper.dart';
import 'package:lms/core/errors/exceptions.dart';
import '../models/auth_model.dart';

class AuthLocalDataSource {
  final CacheHelper cache;
  final String key = "CachedAuthToken";

  AuthLocalDataSource({required this.cache});

  cacheAuthData(AuthModel? authToCache) {
    if (authToCache != null) {
      cache.saveData(
        key: key,
        value: json.encode(authToCache.toJson()),
      );
    } else {
      throw CacheException(errorMessage: "No data to cache");
    }
  }

  Future<AuthModel> getCachedAuthData() {
    final jsonString = cache.getDataString(key: key);

    if (jsonString != null) {
      return Future.value(AuthModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException(errorMessage: "No cached token found");
    }
  }
}