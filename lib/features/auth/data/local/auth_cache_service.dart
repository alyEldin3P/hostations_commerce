import 'dart:convert';
import 'package:hostations_commerce/core/services/cache/cache_service.dart';
import 'package:hostations_commerce/features/auth/data/model/user.dart';
import 'package:hostations_commerce/features/auth/domain/entities/user.dart';

class AuthCacheService {
  final CacheService _cacheService;
  static const String _userKey = 'cached_user';
  static const String _accessTokenKey = 'user_access_token';
  static const String _isLoggedInKey = 'is_logged_in';

  AuthCacheService({required CacheService cacheService}) : _cacheService = cacheService;

  Future<void> cacheUser(User user) async {
    final userMap = (user as UserModel).toJson();
    await _cacheService.setString(_userKey, jsonEncode(userMap));
    await _cacheService.setBool(_isLoggedInKey, true);
  }

  Future<void> cacheAccessToken(String token) async {
    await _cacheService.setString(_accessTokenKey, token);
  }

  Future<User?> getCachedUser() async {
    final userString = _cacheService.getString(_userKey);
    if (userString == null) return null;

    try {
      final userMap = jsonDecode(userString) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    return _cacheService.getString(_accessTokenKey);
  }

  Future<bool> isLoggedIn() async {
    return _cacheService.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearCache() async {
    await _cacheService.remove(_userKey);
    await _cacheService.remove(_accessTokenKey);
    await _cacheService.remove(_isLoggedInKey);
  }
}
