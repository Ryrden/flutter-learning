import '../entities/user.dart';
import '../entities/user_profile.dart';

/// Repository interface for user operations
/// Follows Interface Segregation Principle - focused on user-specific operations
abstract class UserRepository {
  /// Create a new user
  Future<User> createUser({
    required String name,
    required String email,
  });

  /// Get user by ID
  Future<User?> getUserById(String userId);

  /// Get user by email
  Future<User?> getUserByEmail(String email);

  /// Update user profile
  Future<User> updateUserProfile({
    required String userId,
    required UserProfile profile,
  });

  /// Update user basic information
  Future<User> updateUser({
    required String userId,
    String? name,
    String? email,
  });

  /// Delete user
  Future<void> deleteUser(String userId);

  /// Get multiple users by IDs
  Future<List<User>> getUsersByIds(List<String> userIds);
}