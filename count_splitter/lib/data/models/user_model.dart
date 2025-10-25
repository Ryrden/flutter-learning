import '../../domain/entities/user.dart';
import 'user_profile_model.dart';

/// Data model for User with JSON serialization
/// Follows Open/Closed Principle - extends domain entity with serialization
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.profile,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      profile: user.profile != null ? UserProfileModel.fromEntity(user.profile!) : null,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profile: json['profile'] != null 
          ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile': profile != null ? (profile as UserProfileModel).toJson() : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create copy as model
  UserModel copyWithModel({
    String? id,
    String? name,
    String? email,
    UserProfileModel? profile,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profile: profile ?? (this.profile != null ? this.profile as UserProfileModel : null),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}