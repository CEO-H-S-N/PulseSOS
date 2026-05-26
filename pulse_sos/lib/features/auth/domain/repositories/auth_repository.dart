import '../entities/user_entity.dart';

/// Auth repository interface - domain layer contract
abstract class AuthRepository {
  /// Sign in with phone number (sends OTP)
  Future<String> signInWithPhone(String phoneNumber);

  /// Verify OTP code
  Future<UserEntity> verifyOtp(String verificationId, String otp);

  /// Sign in with Google
  Future<UserEntity> signInWithGoogle();

  /// Sign in with email/password
  Future<UserEntity> signInWithEmail(String email, String password);

  /// Register with email/password
  Future<UserEntity> registerWithEmail(String email, String password, String name);

  /// Get current user
  Future<UserEntity?> getCurrentUser();

  /// Update user profile
  Future<UserEntity> updateProfile(UserEntity user);

  /// Sign out
  Future<void> signOut();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Bind device token
  Future<void> bindDevice(String deviceToken);

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;
}
