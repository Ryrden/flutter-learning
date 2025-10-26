import 'package:flutter/foundation.dart';
import '../../domain/entities/group.dart';
import '../../domain/usecases/create_group.dart';
import '../../domain/usecases/get_groups.dart';

/// Provider for managing group state
/// Handles loading, creating, and updating groups
class GroupProvider with ChangeNotifier {
  final CreateGroup _createGroup;
  final GetGroupsForUser _getGroupsForUser;
  final AddMemberToGroup _addMemberToGroup;
  final GetGroupById _getGroupById;

  GroupProvider({
    required CreateGroup createGroup,
    required GetGroupsForUser getGroupsForUser,
    required AddMemberToGroup addMemberToGroup,
    required GetGroupById getGroupById,
  }) : _createGroup = createGroup,
       _getGroupsForUser = getGroupsForUser,
       _addMemberToGroup = addMemberToGroup,
       _getGroupById = getGroupById;

  List<Group> _groups = [];
  bool _isLoading = false;
  String? _error;
  Group? _selectedGroup;

  // Getters
  List<Group> get groups => _groups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Group? get selectedGroup => _selectedGroup;

  /// Load groups for the current user
  Future<void> loadGroups({String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For demo purposes, use a default user ID
      // In a real app, this would come from authentication
      final currentUserId = userId ?? 'current_user';
      final groups = await _getGroupsForUser.call(
        GetGroupsForUserParams(userId: currentUserId),
      );
      
      _groups = groups;
      _error = null;
    } catch (e) {
      _error = 'Failed to load groups: ${e.toString()}';
      _groups = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new group
  Future<bool> createGroup({
    required String name,
    required String description,
    required String creatorName,
    required String creatorEmail,
    String? creatorId,
    String? currency,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For demo purposes, use a default creator ID
      // In a real app, this would come from authentication
      final currentUserId = creatorId ?? 'current_user';
      
      final group = await _createGroup.call(CreateGroupParams(
        name: name,
        description: description,
        createdBy: currentUserId,
        creatorName: creatorName,
        creatorEmail: creatorEmail,
        currency: currency ?? 'USD',
      ));

      _groups.add(group);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create group: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Add member to group
  Future<bool> addMemberToGroup({
    required String groupId,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      final updatedGroup = await _addMemberToGroup.call(AddMemberToGroupParams(
        groupId: groupId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
      ));

      // Update the group in our local list
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
        if (_selectedGroup?.id == groupId) {
          _selectedGroup = updatedGroup;
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Failed to add member: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Load a specific group by ID
  Future<void> loadGroup(String groupId) async {
    try {
      final group = await _getGroupById.call(GetGroupByIdParams(groupId: groupId));
      
      _selectedGroup = group;
      _error = null;
      
      // Also update in the groups list if it exists
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1 && group != null) {
        _groups[index] = group;
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load group: ${e.toString()}';
      _selectedGroup = null;
      notifyListeners();
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear selected group
  void clearSelectedGroup() {
    _selectedGroup = null;
    notifyListeners();
  }
}