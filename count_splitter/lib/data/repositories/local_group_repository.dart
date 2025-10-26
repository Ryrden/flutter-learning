import 'package:uuid/uuid.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../models/group_model.dart';

/// Local implementation of GroupRepository for testing and development
/// Follows Dependency Inversion Principle - implements abstract interface
class LocalGroupRepository implements GroupRepository {
  final Map<String, GroupModel> _groups = {};
  final Uuid _uuid = const Uuid();

  @override
  Future<Group> createGroup({
    required String name,
    required String description,
    required String createdBy,
    String currency = 'USD',
    List<GroupMember> initialMembers = const [],
  }) async {
    final group = GroupModel(
      id: _uuid.v4(),
      name: name,
      description: description,
      createdBy: createdBy,
      members: initialMembers.map((m) => GroupMemberModel.fromEntity(m)).toList(),
      currency: currency,
      createdAt: DateTime.now(),
    );

    _groups[group.id] = group;
    return group;
  }

  @override
  Future<Group?> getGroupById(String groupId) async {
    return _groups[groupId];
  }

  @override
  Future<List<Group>> getGroupsForUser(String userId) async {
    return _groups.values
        .where((group) => group.hasMember(userId))
        .toList();
  }

  @override
  Future<Group> updateGroup({
    required String groupId,
    String? name,
    String? description,
    bool? allowSmartSplit,
    bool? showAmountsToAll,
  }) async {
    final existingGroup = _groups[groupId];
    if (existingGroup == null) {
      throw Exception('Group not found');
    }

    final updatedGroup = existingGroup.copyWithModel(
      name: name,
      description: description,
      allowSmartSplit: allowSmartSplit,
      showAmountsToAll: showAmountsToAll,
      updatedAt: DateTime.now(),
    );

    _groups[groupId] = updatedGroup;
    return updatedGroup;
  }

  @override
  Future<Group> addMemberToGroup({
    required String groupId,
    required GroupMember member,
  }) async {
    final existingGroup = _groups[groupId];
    if (existingGroup == null) {
      throw Exception('Group not found');
    }

    if (existingGroup.hasMember(member.userId)) {
      throw Exception('User is already a member of this group');
    }

    final updatedGroup = existingGroup.addMember(GroupMemberModel.fromEntity(member));
    final updatedGroupModel = GroupModel.fromEntity(updatedGroup);
    _groups[groupId] = updatedGroupModel;
    return updatedGroup;
  }

  @override
  Future<Group> removeMemberFromGroup({
    required String groupId,
    required String userId,
  }) async {
    final existingGroup = _groups[groupId];
    if (existingGroup == null) {
      throw Exception('Group not found');
    }

    if (!existingGroup.hasMember(userId)) {
      throw Exception('User is not a member of this group');
    }

    // Don't allow removing the creator
    if (existingGroup.createdBy == userId) {
      throw Exception('Cannot remove the group creator');
    }

    final updatedGroup = existingGroup.removeMember(userId);
    final updatedGroupModel = GroupModel.fromEntity(updatedGroup);
    _groups[groupId] = updatedGroupModel;
    return updatedGroup;
  }

  @override
  Future<Group> updateMemberInGroup({
    required String groupId,
    required String userId,
    required GroupMember updatedMember,
  }) async {
    final existingGroup = _groups[groupId];
    if (existingGroup == null) {
      throw Exception('Group not found');
    }

    if (!existingGroup.hasMember(userId)) {
      throw Exception('User is not a member of this group');
    }

    final updatedGroup = existingGroup.updateMember(userId, GroupMemberModel.fromEntity(updatedMember));
    final updatedGroupModel = GroupModel.fromEntity(updatedGroup);
    _groups[groupId] = updatedGroupModel;
    return updatedGroup;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    _groups.remove(groupId);
  }

  @override
  Future<bool> isUserMemberOfGroup({
    required String userId,
    required String groupId,
  }) async {
    final group = _groups[groupId];
    return group?.hasMember(userId) ?? false;
  }

  // Helper methods for testing
  void clear() {
    _groups.clear();
  }

  List<Group> getAllGroups() {
    return _groups.values.toList();
  }

  int get groupCount => _groups.length;
}