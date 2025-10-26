import 'package:equatable/equatable.dart';
import 'user.dart';

/// Represents a group member with additional metadata
class GroupMember extends Equatable {
  final String userId;
  final String name;
  final String email;
  final DateTime joinedAt;
  final bool isActive;

  const GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.joinedAt,
    this.isActive = true,
  });

  GroupMember copyWith({
    String? userId,
    String? name,
    String? email,
    DateTime? joinedAt,
    bool? isActive,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [userId, name, email, joinedAt, isActive];
}

/// Represents a group of users who share expenses
/// Follows Single Responsibility Principle - manages group membership and settings
class Group extends Equatable {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final List<GroupMember> members;
  final String currency;
  final bool allowSmartSplit;
  final bool showAmountsToAll;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.members,
    this.currency = 'USD',
    this.allowSmartSplit = true,
    this.showAmountsToAll = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get list of member IDs
  List<String> get memberIds => members.map((m) => m.userId).toList();

  /// Check if all members have complete profiles for smart splitting
  bool canUseSmartSplit(List<User> users) {
    if (!allowSmartSplit) return false;
    if (users.length != members.length) return false;
    
    return users.every((user) => user.hasCompleteProfile && user.allowsSmartSplit);
  }

  /// Check if user is member of this group
  bool hasMember(String userId) => members.any((m) => m.userId == userId);

  /// Get member by user ID
  GroupMember? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (e) {
      return null;
    }
  }

  /// Get number of active members
  int get memberCount => members.where((m) => m.isActive).length;

  /// Get active members only
  List<GroupMember> get activeMembers => members.where((m) => m.isActive).toList();

  /// Check if user is the creator of this group
  bool isCreatedBy(String userId) => createdBy == userId;

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    List<GroupMember>? members,
    String? currency,
    bool? allowSmartSplit,
    bool? showAmountsToAll,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      currency: currency ?? this.currency,
      allowSmartSplit: allowSmartSplit ?? this.allowSmartSplit,
      showAmountsToAll: showAmountsToAll ?? this.showAmountsToAll,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Group addMember(GroupMember member) {
    if (hasMember(member.userId)) return this;
    
    return copyWith(
      members: [...members, member],
      updatedAt: DateTime.now(),
    );
  }

  Group removeMember(String userId) {
    if (!hasMember(userId)) return this;
    
    return copyWith(
      members: members.where((m) => m.userId != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  Group updateMember(String userId, GroupMember updatedMember) {
    final memberIndex = members.indexWhere((m) => m.userId == userId);
    if (memberIndex == -1) return this;

    final updatedMembers = [...members];
    updatedMembers[memberIndex] = updatedMember;
    
    return copyWith(
      members: updatedMembers,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        createdBy,
        members,
        currency,
        allowSmartSplit,
        showAmountsToAll,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Group(id: $id, name: $name, members: ${members.length})';
  }
}