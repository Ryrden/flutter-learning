import 'user_profile.dart';

/// Represents a user in the expense splitting system
/// Follows Single Responsibility Principle - handles user identity and profile
class User {
  final String id;
  final String name;
  final String email;
  final UserProfile? profile;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profile,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if user has completed their financial profile
  bool get hasCompleteProfile => profile != null && profile!.hasValidFunBudget;

  /// Check if user allows smart splitting
  bool get allowsSmartSplit => profile?.allowSmartSplit ?? false;

  /// Get user's monthly fun budget or 0 if no profile
  double get funBudget => profile?.monthlyFunBudget ?? 0.0;

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserProfile? profile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profile: profile ?? this.profile,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profile == profile &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        profile.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, hasProfile: ${profile != null})';
  }
}