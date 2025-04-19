import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';

class SharedPreferencesCacheService implements CacheService {
  final SharedPreferences _preferences;

  SharedPreferencesCacheService(this._preferences);

  @override
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences.setBool(key, value);
    } catch (e) {
      log('Error setting bool for key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    try {
      return await _preferences.setInt(key, value);
    } catch (e) {
      log('Error setting int for key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _preferences.setDouble(key, value);
    } catch (e) {
      log('Error setting double for key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> setString(String key, String value) async {
    try {
      return await _preferences.setString(key, value);
    } catch (e) {
      log('Error setting string for key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _preferences.setStringList(key, value);
    } catch (e) {
      log('Error setting string list for key $key: $e');
      return false;
    }
  }

  @override
  bool? getBool(String key) {
    try {
      return _preferences.getBool(key);
    } catch (e) {
      log('Error getting bool for key $key: $e');
      return null;
    }
  }

  @override
  int? getInt(String key) {
    try {
      return _preferences.getInt(key);
    } catch (e) {
      log('Error getting int for key $key: $e');
      return null;
    }
  }

  @override
  double? getDouble(String key) {
    try {
      return _preferences.getDouble(key);
    } catch (e) {
      log('Error getting double for key $key: $e');
      return null;
    }
  }

  @override
  String? getString(String key) {
    try {
      return _preferences.getString(key);
    } catch (e) {
      log('Error getting string for key $key: $e');
      return null;
    }
  }

  @override
  List<String>? getStringList(String key) {
    try {
      return _preferences.getStringList(key);
    } catch (e) {
      log('Error getting string list for key $key: $e');
      return null;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      return await _preferences.remove(key);
    } catch (e) {
      log('Error removing key $key: $e');
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _preferences.clear();
    } catch (e) {
      log('Error clearing preferences: $e');
      return false;
    }
  }

  @override
  bool containsKey(String key) {
    try {
      return _preferences.containsKey(key);
    } catch (e) {
      log('Error checking if key $key exists: $e');
      return false;
    }
  }
}
