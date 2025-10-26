import '../../domain/entities/group.dart';

/// Data model for GroupMember with JSON serialization
class GroupMemberModel extends GroupMember {
  const GroupMemberModel({
    required super.userId,
    required super.name,
    required super.email,
    required super.joinedAt,
    super.isActive,
  });

  /// Create from domain entity
  factory GroupMemberModel.fromEntity(GroupMember member) {
    return GroupMemberModel(
      userId: member.userId,
      name: member.name,
      email: member.email,
      joinedAt: member.joinedAt,
      isActive: member.isActive,
    );
  }

  /// Create from JSON
  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    return GroupMemberModel(
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}

/// Data model for Group with JSON serialization
/// Follows Open/Closed Principle - extends domain entity with serialization
class GroupModel extends Group {
  const GroupModel({
    required super.id,
    required super.name,
    required super.description,
    required super.createdBy,
    required super.members,
    super.currency,
    super.allowSmartSplit,
    super.showAmountsToAll,
    required super.createdAt,
    super.updatedAt,
  });

  /// Create from domain entity
  factory GroupModel.fromEntity(Group group) {
    return GroupModel(
      id: group.id,
      name: group.name,
      description: group.description,
      createdBy: group.createdBy,
      members: group.members.map((m) => GroupMemberModel.fromEntity(m)).toList(),
      currency: group.currency,
      allowSmartSplit: group.allowSmartSplit,
      showAmountsToAll: group.showAmountsToAll,
      createdAt: group.createdAt,
      updatedAt: group.updatedAt,
    );
  }

  /// Create from JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdBy: json['createdBy'] as String,
      members: (json['members'] as List<dynamic>? ?? [])
          .map((memberJson) => GroupMemberModel.fromJson(memberJson as Map<String, dynamic>))
          .toList(),
      currency: json['currency'] as String? ?? 'USD',
      allowSmartSplit: json['allowSmartSplit'] as bool? ?? true,
      showAmountsToAll: json['showAmountsToAll'] as bool? ?? false,
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
      'description': description,
      'createdBy': createdBy,
      'members': members.map((m) => (m as GroupMemberModel).toJson()).toList(),
      'currency': currency,
      'allowSmartSplit': allowSmartSplit,
      'showAmountsToAll': showAmountsToAll,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create copy as model
  GroupModel copyWithModel({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    List<GroupMemberModel>? members,
    String? currency,
    bool? allowSmartSplit,
    bool? showAmountsToAll,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members.cast<GroupMemberModel>(),
      currency: currency ?? this.currency,
      allowSmartSplit: allowSmartSplit ?? this.allowSmartSplit,
      showAmountsToAll: showAmountsToAll ?? this.showAmountsToAll,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}