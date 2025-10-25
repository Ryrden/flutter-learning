import 'user.dart';

/// Represents a group of users who share expenses
/// Follows Single Responsibility Principle - manages group membership and settings
class Group {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final List<String> memberIds;
  final bool allowSmartSplit;
  final bool showAmountsToAll;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.memberIds,
    this.allowSmartSplit = true,
    this.showAmountsToAll = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Check if all members have complete profiles for smart splitting
  bool canUseSmartSplit(List<User> members) {
    if (!allowSmartSplit) return false;
    if (members.length != memberIds.length) return false;
    
    return members.every((user) => user.hasCompleteProfile && user.allowsSmartSplit);
  }

  /// Check if user is member of this group
  bool hasMember(String userId) => memberIds.contains(userId);

  /// Get number of members
  int get memberCount => memberIds.length;

  /// Check if user is the creator of this group
  bool isCreatedBy(String userId) => createdBy == userId;

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    List<String>? memberIds,
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
      memberIds: memberIds ?? this.memberIds,
      allowSmartSplit: allowSmartSplit ?? this.allowSmartSplit,
      showAmountsToAll: showAmountsToAll ?? this.showAmountsToAll,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Group addMember(String userId) {
    if (hasMember(userId)) return this;
    
    return copyWith(
      memberIds: [...memberIds, userId],
      updatedAt: DateTime.now(),
    );
  }

  Group removeMember(String userId) {
    if (!hasMember(userId)) return this;
    
    return copyWith(
      memberIds: memberIds.where((id) => id != userId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Group &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.createdBy == createdBy &&
        _listEquals(other.memberIds, memberIds) &&
        other.allowSmartSplit == allowSmartSplit &&
        other.showAmountsToAll == showAmountsToAll &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        createdBy.hashCode ^
        memberIds.hashCode ^
        allowSmartSplit.hashCode ^
        showAmountsToAll.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }

  @override
  String toString() {
    return 'Group(id: $id, name: $name, members: ${memberIds.length})';
  }

  // Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}