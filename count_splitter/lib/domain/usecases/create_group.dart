import '../entities/group.dart';
import '../repositories/group_repository.dart';
import 'usecase.dart';

/// Parameters for creating a group
class CreateGroupParams {
  final String name;
  final String description;
  final String createdBy;
  final String creatorName;
  final String creatorEmail;
  final String currency;

  const CreateGroupParams({
    required this.name,
    required this.description,
    required this.createdBy,
    required this.creatorName,
    required this.creatorEmail,
    this.currency = 'USD',
  });
}

/// Use case for creating a new group
/// Follows Single Responsibility Principle - only handles group creation
class CreateGroup extends UseCase<Group, CreateGroupParams> {
  final GroupRepository repository;

  CreateGroup(this.repository);

  @override
  Future<Group> call(CreateGroupParams params) async {
    // Validate input
    if (params.name.trim().isEmpty) {
      throw ArgumentError('Group name cannot be empty');
    }

    if (params.name.trim().length < 2) {
      throw ArgumentError('Group name must be at least 2 characters');
    }

    if (params.name.trim().length > 50) {
      throw ArgumentError('Group name cannot exceed 50 characters');
    }

    if (params.description.length > 200) {
      throw ArgumentError('Description cannot exceed 200 characters');
    }

    // Create the creator as the first member
    final creator = GroupMember(
      userId: params.createdBy,
      name: params.creatorName,
      email: params.creatorEmail,
      joinedAt: DateTime.now(),
    );

    // Create the group
    return await repository.createGroup(
      name: params.name.trim(),
      description: params.description.trim(),
      createdBy: params.createdBy,
      currency: params.currency,
      initialMembers: [creator],
    );
  }
}