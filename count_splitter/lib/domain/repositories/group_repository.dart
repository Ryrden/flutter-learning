import '../entities/group.dart';

/// Repository interface for group operations
/// Follows Interface Segregation Principle - focused on group-specific operations
abstract class GroupRepository {
  /// Create a new group
  Future<Group> createGroup({
    required String name,
    required String description,
    required String createdBy,
    String currency = 'USD',
    List<GroupMember> initialMembers = const [],
  });

  /// Get group by ID
  Future<Group?> getGroupById(String groupId);

  /// Get all groups for a user
  Future<List<Group>> getGroupsForUser(String userId);

  /// Update group information
  Future<Group> updateGroup({
    required String groupId,
    String? name,
    String? description,
    bool? allowSmartSplit,
    bool? showAmountsToAll,
  });

  /// Add member to group
  Future<Group> addMemberToGroup({
    required String groupId,
    required GroupMember member,
  });

  /// Remove member from group
  Future<Group> removeMemberFromGroup({
    required String groupId,
    required String userId,
  });

  /// Update member in group
  Future<Group> updateMemberInGroup({
    required String groupId,
    required String userId,
    required GroupMember updatedMember,
  });

  /// Delete group
  Future<void> deleteGroup(String groupId);

  /// Check if user is member of group
  Future<bool> isUserMemberOfGroup({
    required String userId,
    required String groupId,
  });
}