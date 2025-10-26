import '../entities/group.dart';
import '../repositories/group_repository.dart';
import 'usecase.dart';

/// Parameters for adding a member to a group
class AddMemberToGroupParams {
  final String groupId;
  final String userId;
  final String userName;
  final String userEmail;

  const AddMemberToGroupParams({
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });
}

/// Use case for adding a member to a group
class AddMemberToGroup extends UseCase<Group, AddMemberToGroupParams> {
  final GroupRepository repository;

  AddMemberToGroup(this.repository);

  @override
  Future<Group> call(AddMemberToGroupParams params) async {
    // Validate input
    if (params.userName.trim().isEmpty) {
      throw ArgumentError('User name cannot be empty');
    }

    if (params.userEmail.trim().isEmpty) {
      throw ArgumentError('User email cannot be empty');
    }

    // Create the new member
    final member = GroupMember(
      userId: params.userId,
      name: params.userName.trim(),
      email: params.userEmail.trim(),
      joinedAt: DateTime.now(),
    );

    return await repository.addMemberToGroup(
      groupId: params.groupId,
      member: member,
    );
  }
}

/// Parameters for getting groups for a user
class GetGroupsForUserParams {
  final String userId;

  const GetGroupsForUserParams({required this.userId});
}

/// Use case for getting all groups for a user
class GetGroupsForUser extends UseCase<List<Group>, GetGroupsForUserParams> {
  final GroupRepository repository;

  GetGroupsForUser(this.repository);

  @override
  Future<List<Group>> call(GetGroupsForUserParams params) async {
    if (params.userId.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty');
    }

    return await repository.getGroupsForUser(params.userId);
  }
}

/// Parameters for getting a group by ID
class GetGroupByIdParams {
  final String groupId;

  const GetGroupByIdParams({required this.groupId});
}

/// Use case for getting a group by its ID
class GetGroupById extends UseCase<Group?, GetGroupByIdParams> {
  final GroupRepository repository;

  GetGroupById(this.repository);

  @override
  Future<Group?> call(GetGroupByIdParams params) async {
    if (params.groupId.trim().isEmpty) {
      throw ArgumentError('Group ID cannot be empty');
    }

    return await repository.getGroupById(params.groupId);
  }
}