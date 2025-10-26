import 'package:flutter_test/flutter_test.dart';
import 'package:count_splitter/domain/entities/group.dart';
import 'package:count_splitter/domain/entities/category.dart';
import 'package:count_splitter/domain/usecases/create_group.dart';
import 'package:count_splitter/domain/usecases/get_groups.dart';
import 'package:count_splitter/data/repositories/local_group_repository.dart';

void main() {
  group('Category Tests', () {
    test('should have correct category properties', () {
      expect(ExpenseCategory.food.displayName, equals('Food & Dining'));
      expect(ExpenseCategory.transport.displayName, equals('Transport'));
      expect(ExpenseCategory.entertainment.displayName, equals('Entertainment'));
    });

    test('should find category by string', () {
      expect(ExpenseCategory.fromString('food'), equals(ExpenseCategory.food));
      expect(ExpenseCategory.fromString('FOOD'), equals(ExpenseCategory.food));
      expect(ExpenseCategory.fromString('invalid'), isNull);
    });

    test('should return all categories', () {
      final categories = ExpenseCategory.getAllCategories();
      expect(categories.length, equals(10));
      expect(categories.contains(ExpenseCategory.food), isTrue);
      expect(categories.contains(ExpenseCategory.other), isTrue);
    });

    test('should return popular categories', () {
      final popular = ExpenseCategory.getPopularCategories();
      expect(popular.length, equals(5));
      expect(popular.contains(ExpenseCategory.food), isTrue);
      expect(popular.contains(ExpenseCategory.transport), isTrue);
    });
  });

  group('Group Entity Tests', () {
    late GroupMember testMember1;
    late GroupMember testMember2;
    late Group testGroup;

    setUp(() {
      testMember1 = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      testMember2 = GroupMember(
        userId: 'user2',
        name: 'Bob',
        email: 'bob@test.com',
        joinedAt: DateTime.now(),
      );

      testGroup = Group(
        id: 'group1',
        name: 'Test Group',
        description: 'A test group',
        createdBy: 'user1',
        members: [testMember1, testMember2],
        createdAt: DateTime.now(),
      );
    });

    test('should check if user is member', () {
      expect(testGroup.hasMember('user1'), isTrue);
      expect(testGroup.hasMember('user2'), isTrue);
      expect(testGroup.hasMember('user3'), isFalse);
    });

    test('should get member by user ID', () {
      final member = testGroup.getMember('user1');
      expect(member, isNotNull);
      expect(member!.name, equals('Alice'));

      final nonExistentMember = testGroup.getMember('user99');
      expect(nonExistentMember, isNull);
    });

    test('should return correct member count', () {
      expect(testGroup.memberCount, equals(2));
    });

    test('should get member IDs', () {
      final memberIds = testGroup.memberIds;
      expect(memberIds, equals(['user1', 'user2']));
    });

    test('should add member successfully', () {
      final newMember = GroupMember(
        userId: 'user3',
        name: 'Charlie',
        email: 'charlie@test.com',
        joinedAt: DateTime.now(),
      );

      final updatedGroup = testGroup.addMember(newMember);
      expect(updatedGroup.memberCount, equals(3));
      expect(updatedGroup.hasMember('user3'), isTrue);
    });

    test('should not add duplicate member', () {
      final updatedGroup = testGroup.addMember(testMember1);
      expect(updatedGroup.memberCount, equals(2)); // Should remain the same
    });

    test('should remove member successfully', () {
      final updatedGroup = testGroup.removeMember('user2');
      expect(updatedGroup.memberCount, equals(1));
      expect(updatedGroup.hasMember('user2'), isFalse);
      expect(updatedGroup.hasMember('user1'), isTrue);
    });

    test('should handle removing non-existent member', () {
      final updatedGroup = testGroup.removeMember('user99');
      expect(updatedGroup.memberCount, equals(2)); // Should remain the same
    });

    test('should update member successfully', () {
      final updatedMember = testMember1.copyWith(name: 'Alice Updated');
      final updatedGroup = testGroup.updateMember('user1', updatedMember);
      
      final member = updatedGroup.getMember('user1');
      expect(member!.name, equals('Alice Updated'));
    });
  });

  group('CreateGroup Use Case Tests', () {
    late CreateGroup createGroup;
    late LocalGroupRepository repository;

    setUp(() {
      repository = LocalGroupRepository();
      createGroup = CreateGroup(repository);
    });

    tearDown(() {
      repository.clear();
    });

    test('should create group successfully', () async {
      // Arrange
      final params = CreateGroupParams(
        name: 'Trip to Beach',
        description: 'Summer vacation expenses',
        createdBy: 'user1',
        creatorName: 'Alice',
        creatorEmail: 'alice@test.com',
        currency: 'USD',
      );

      // Act
      final group = await createGroup(params);

      // Assert
      expect(group.name, equals('Trip to Beach'));
      expect(group.description, equals('Summer vacation expenses'));
      expect(group.createdBy, equals('user1'));
      expect(group.currency, equals('USD'));
      expect(group.memberCount, equals(1));
      expect(group.hasMember('user1'), isTrue);
      
      final creator = group.getMember('user1');
      expect(creator!.name, equals('Alice'));
      expect(creator.email, equals('alice@test.com'));
    });

    test('should throw error for empty group name', () async {
      // Arrange
      final params = CreateGroupParams(
        name: '',
        description: 'Test',
        createdBy: 'user1',
        creatorName: 'Alice',
        creatorEmail: 'alice@test.com',
      );

      // Act & Assert
      expect(
        () => createGroup(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for short group name', () async {
      // Arrange
      final params = CreateGroupParams(
        name: 'A',
        description: 'Test',
        createdBy: 'user1',
        creatorName: 'Alice',
        creatorEmail: 'alice@test.com',
      );

      // Act & Assert
      expect(
        () => createGroup(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for long group name', () async {
      // Arrange
      final params = CreateGroupParams(
        name: 'A' * 51, // 51 characters
        description: 'Test',
        createdBy: 'user1',
        creatorName: 'Alice',
        creatorEmail: 'alice@test.com',
      );

      // Act & Assert
      expect(
        () => createGroup(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for long description', () async {
      // Arrange
      final params = CreateGroupParams(
        name: 'Valid Name',
        description: 'A' * 201, // 201 characters
        createdBy: 'user1',
        creatorName: 'Alice',
        creatorEmail: 'alice@test.com',
      );

      // Act & Assert
      expect(
        () => createGroup(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should trim whitespace from name and description', () async {
      // Arrange
      final params = CreateGroupParams(
        name: '  Trip to Beach  ',
        description: '  Summer vacation  ',
        createdBy: 'user1',
        creatorName: 'Alice',
        creatorEmail: 'alice@test.com',
      );

      // Act
      final group = await createGroup(params);

      // Assert
      expect(group.name, equals('Trip to Beach'));
      expect(group.description, equals('Summer vacation'));
    });
  });

  group('LocalGroupRepository Tests', () {
    late LocalGroupRepository repository;

    setUp(() {
      repository = LocalGroupRepository();
    });

    tearDown(() {
      repository.clear();
    });

    test('should create and retrieve group', () async {
      // Arrange
      final creator = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      // Act
      final group = await repository.createGroup(
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user1',
        initialMembers: [creator],
      );

      final retrievedGroup = await repository.getGroupById(group.id);

      // Assert
      expect(retrievedGroup, isNotNull);
      expect(retrievedGroup!.id, equals(group.id));
      expect(retrievedGroup.name, equals('Test Group'));
    });

    test('should get groups for user', () async {
      // Arrange
      final user1 = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      final user2 = GroupMember(
        userId: 'user2',
        name: 'Bob',
        email: 'bob@test.com',
        joinedAt: DateTime.now(),
      );

      await repository.createGroup(
        name: 'Group 1',
        description: 'First group',
        createdBy: 'user1',
        initialMembers: [user1],
      );

      await repository.createGroup(
        name: 'Group 2',
        description: 'Second group',
        createdBy: 'user1',
        initialMembers: [user1, user2],
      );

      await repository.createGroup(
        name: 'Group 3',
        description: 'Third group',
        createdBy: 'user2',
        initialMembers: [user2],
      );

      // Act
      final user1Groups = await repository.getGroupsForUser('user1');
      final user2Groups = await repository.getGroupsForUser('user2');

      // Assert
      expect(user1Groups.length, equals(2));
      expect(user2Groups.length, equals(2));
    });

    test('should add member to group', () async {
      // Arrange
      final creator = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      final group = await repository.createGroup(
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user1',
        initialMembers: [creator],
      );

      final newMember = GroupMember(
        userId: 'user2',
        name: 'Bob',
        email: 'bob@test.com',
        joinedAt: DateTime.now(),
      );

      // Act
      final updatedGroup = await repository.addMemberToGroup(
        groupId: group.id,
        member: newMember,
      );

      // Assert
      expect(updatedGroup.memberCount, equals(2));
      expect(updatedGroup.hasMember('user2'), isTrue);
    });

    test('should not add duplicate member', () async {
      // Arrange
      final creator = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      final group = await repository.createGroup(
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user1',
        initialMembers: [creator],
      );

      // Act & Assert
      expect(
        () => repository.addMemberToGroup(
          groupId: group.id,
          member: creator,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should remove member from group', () async {
      // Arrange
      final creator = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      final member = GroupMember(
        userId: 'user2',
        name: 'Bob',
        email: 'bob@test.com',
        joinedAt: DateTime.now(),
      );

      final group = await repository.createGroup(
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user1',
        initialMembers: [creator, member],
      );

      // Act
      final updatedGroup = await repository.removeMemberFromGroup(
        groupId: group.id,
        userId: 'user2',
      );

      // Assert
      expect(updatedGroup.memberCount, equals(1));
      expect(updatedGroup.hasMember('user2'), isFalse);
      expect(updatedGroup.hasMember('user1'), isTrue);
    });

    test('should not allow removing group creator', () async {
      // Arrange
      final creator = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      final group = await repository.createGroup(
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user1',
        initialMembers: [creator],
      );

      // Act & Assert
      expect(
        () => repository.removeMemberFromGroup(
          groupId: group.id,
          userId: 'user1', // Try to remove creator
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should delete group', () async {
      // Arrange
      final creator = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      final group = await repository.createGroup(
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user1',
        initialMembers: [creator],
      );

      // Act
      await repository.deleteGroup(group.id);
      final retrievedGroup = await repository.getGroupById(group.id);

      // Assert
      expect(retrievedGroup, isNull);
    });
  });

  group('AddMemberToGroup Use Case Tests', () {
    late AddMemberToGroup addMemberToGroup;
    late LocalGroupRepository repository;
    late Group testGroup;

    setUp(() async {
      repository = LocalGroupRepository();
      addMemberToGroup = AddMemberToGroup(repository);
      
      final creator = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      testGroup = await repository.createGroup(
        name: 'Test Group',
        description: 'Description',
        createdBy: 'user1',
        initialMembers: [creator],
      );
    });

    tearDown(() {
      repository.clear();
    });

    test('should add member to group successfully', () async {
      // Arrange
      final params = AddMemberToGroupParams(
        groupId: testGroup.id,
        userId: 'user2',
        userName: 'Bob',
        userEmail: 'bob@test.com',
      );

      // Act
      final updatedGroup = await addMemberToGroup(params);

      // Assert
      expect(updatedGroup.memberCount, equals(2));
      expect(updatedGroup.hasMember('user2'), isTrue);
      
      final newMember = updatedGroup.getMember('user2');
      expect(newMember!.name, equals('Bob'));
      expect(newMember.email, equals('bob@test.com'));
    });

    test('should throw error for empty user name', () async {
      // Arrange
      final params = AddMemberToGroupParams(
        groupId: testGroup.id,
        userId: 'user2',
        userName: '',
        userEmail: 'bob@test.com',
      );

      // Act & Assert
      expect(
        () => addMemberToGroup(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for empty user email', () async {
      // Arrange
      final params = AddMemberToGroupParams(
        groupId: testGroup.id,
        userId: 'user2',
        userName: 'Bob',
        userEmail: '',
      );

      // Act & Assert
      expect(
        () => addMemberToGroup(params),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('GetGroupsForUser Use Case Tests', () {
    late GetGroupsForUser getGroupsForUser;
    late LocalGroupRepository repository;

    setUp(() {
      repository = LocalGroupRepository();
      getGroupsForUser = GetGroupsForUser(repository);
    });

    tearDown(() {
      repository.clear();
    });

    test('should get groups for user successfully', () async {
      // Arrange
      final user1 = GroupMember(
        userId: 'user1',
        name: 'Alice',
        email: 'alice@test.com',
        joinedAt: DateTime.now(),
      );

      await repository.createGroup(
        name: 'Group 1',
        description: 'First group',
        createdBy: 'user1',
        initialMembers: [user1],
      );

      await repository.createGroup(
        name: 'Group 2',
        description: 'Second group',
        createdBy: 'user1',
        initialMembers: [user1],
      );

      final params = GetGroupsForUserParams(userId: 'user1');

      // Act
      final groups = await getGroupsForUser(params);

      // Assert
      expect(groups.length, equals(2));
      expect(groups.every((g) => g.hasMember('user1')), isTrue);
    });

    test('should throw error for empty user ID', () async {
      // Arrange
      final params = GetGroupsForUserParams(userId: '');

      // Act & Assert
      expect(
        () => getGroupsForUser(params),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}