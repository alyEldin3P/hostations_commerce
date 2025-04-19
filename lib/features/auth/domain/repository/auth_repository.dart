import 'package:hostations_commerce/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  /// Sign in a user with email and password
  Future<User> signIn({required String email, required String password});

  /// Create a new user account
  Future<User> signUp({
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
  Future<User?> getCurrentUser();

  /// Request a password reset for a given email
  Future<void> forgotPassword(String email);
}
