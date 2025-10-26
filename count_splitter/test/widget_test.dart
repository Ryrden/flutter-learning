// Basic Flutter widget test for Count Splitter app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';


import 'package:count_splitter/presentation/pages/main_page.dart';
import 'package:count_splitter/presentation/providers/group_provider.dart';
import 'package:count_splitter/domain/usecases/create_group.dart';
import 'package:count_splitter/domain/usecases/get_groups.dart';
import 'package:count_splitter/domain/repositories/group_repository.dart';
import 'package:count_splitter/data/repositories/local_group_repository.dart';

void main() {
  testWidgets('App launches and shows main page with bottom navigation', (WidgetTester tester) async {
    // Create test dependencies
    final GroupRepository groupRepository = LocalGroupRepository();
    final CreateGroup createGroup = CreateGroup(groupRepository);
    final GetGroupsForUser getGroupsForUser = GetGroupsForUser(groupRepository);
    final AddMemberToGroup addMemberToGroup = AddMemberToGroup(groupRepository);
    final GetGroupById getGroupById = GetGroupById(groupRepository);

    // Build our app with test dependencies
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => GroupProvider(
              createGroup: createGroup,
              getGroupsForUser: getGroupsForUser,
              addMemberToGroup: addMemberToGroup,
              getGroupById: getGroupById,
            ),
          ),
        ],
        child: MaterialApp(
          home: const MainPage(),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Verify that our app shows the main page elements
    expect(find.text('Groups'), findsWidgets); // Bottom nav and app bar
    expect(find.text('Profile'), findsOneWidget);
    
    // Verify bottom navigation bar is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Verify that the floating action button is present on the Groups page
    expect(find.byType(FloatingActionButton), findsOneWidget);
    
    // Verify we can see the empty state message
    expect(find.text('No groups yet'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches between pages', (WidgetTester tester) async {
    // Create test dependencies
    final GroupRepository groupRepository = LocalGroupRepository();
    final CreateGroup createGroup = CreateGroup(groupRepository);
    final GetGroupsForUser getGroupsForUser = GetGroupsForUser(groupRepository);
    final AddMemberToGroup addMemberToGroup = AddMemberToGroup(groupRepository);
    final GetGroupById getGroupById = GetGroupById(groupRepository);

    // Build our app with test dependencies
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => GroupProvider(
              createGroup: createGroup,
              getGroupsForUser: getGroupsForUser,
              addMemberToGroup: addMemberToGroup,
              getGroupById: getGroupById,
            ),
          ),
        ],
        child: MaterialApp(
          home: const MainPage(),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Initially on Groups page
    expect(find.text('No groups yet'), findsOneWidget);
    
    // Tap on Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    
    // Should now see Profile page - check for the Profile title (appears in bottom nav and app bar)
    expect(find.text('Profile'), findsAtLeastNWidgets(2));
    
    // Tap back on Groups tab
    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    
    // Should be back on Groups page
    expect(find.text('No groups yet'), findsOneWidget);
  });
}
