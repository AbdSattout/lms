import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

//! Here The Initialize of cache .
  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

//! this method to get data from local database using key

  String? getDataString({
    required String key,
  }) {
    return sharedPreferences.getString(key);
  }

//! this method to put data in local database using key

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    }
    if (value is String) {
      return await sharedPreferences.setString(key, value);
    }

    if (value is int) {
      return await sharedPreferences.setInt(key, value);
    } else {
      return await sharedPreferences.setDouble(key, value);
    }
  }

//! this method to get data already saved in local database

  dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

//! remove data using specific key

  Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

//! this method to check if local database contains {key}
  bool containsKey({required String key}) {
    return sharedPreferences.containsKey(key);
  }

//! clear all data in the local database
  Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }

//! this method to put data in local database using key
  Future<bool> put({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) {
      return await sharedPreferences.setString(key, value);
    } else if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    } else if (value is double) {
      return await sharedPreferences.setDouble(key, value);
    } else {
      return await sharedPreferences.setInt(key, value);
    }
  }

  Future<void> saveTheme(ThemeMode mode) async {
    await saveData(
      key: "theme",
      value: mode.name,
    );
  }

  ThemeMode getTheme() {
    final value = getDataString(key: "theme");

    switch (value) {
      case "dark":
        return ThemeMode.dark;
      case "system":
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }
}