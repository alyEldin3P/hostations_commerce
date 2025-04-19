import 'package:hostations_commerce/features/auth/data/model/user.dart';

abstract class AuthRemoteDataSource {
  /// Sign in a user with email and password
  Future<UserModel> signIn({required String email, required String password});

  /// Create a new user account
  Future<UserModel> signUp({
    required String email, 
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    bool acceptsMarketing = false,
  });

  /// Sign out the current user
  Future<void> signOut();

  /// Check if a user is currently signed in
  Future<bool> isSignedIn();

  /// Get the current signed-in user
  Future<UserModel?> getCurrentUser();

  /// Request a password reset for a given email
  Future<void> forgotPassword(String email);
}
