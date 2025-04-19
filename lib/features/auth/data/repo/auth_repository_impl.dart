import 'package:hostations_commerce/features/auth/data/remote/auth_remote_data_source.dart';
import 'package:hostations_commerce/features/auth/data/local/auth_cache_service.dart';
import 'package:hostations_commerce/features/auth/domain/entities/user.dart';
import 'package:hostations_commerce/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthCacheService cacheService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheService,
  });

  @override
  Future<User> signIn({required String email, required String password}) async {
    final user = await remoteDataSource.signIn(email: email, password: password);
    await cacheService.cacheUser(user);
    await cacheService.cacheAccessToken(user.accessToken!);
    return user;
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    bool acceptsMarketing = false,
  }) async {
    final user = await remoteDataSource.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      acceptsMarketing: acceptsMarketing,
    );
    await cacheService.cacheUser(user);
    await cacheService.cacheAccessToken(user.accessToken!);
    return user;
  }

  @override
  Future<void> signOut() async {
    await cacheService.clearCache();
    await remoteDataSource.signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    return await cacheService.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() async {
    final cachedUser = await cacheService.getCachedUser();
    if (cachedUser != null) {
      return cachedUser;
    }
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> forgotPassword(String email) async {
    await remoteDataSource.forgotPassword(email);
  }
}
