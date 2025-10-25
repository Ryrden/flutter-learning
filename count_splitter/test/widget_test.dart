// Basic Flutter widget test for Count Splitter app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:count_splitter/main.dart';

void main() {
  testWidgets('App launches and shows home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CountSplitterApp());

    // Verify that our app shows the welcome message.
    expect(find.text('Welcome to Count Splitter'), findsOneWidget);
    expect(find.text('My Groups'), findsOneWidget);
    expect(find.text('Profile Setup'), findsOneWidget);
    expect(find.text('Recent Expenses'), findsOneWidget);

    // Verify that the floating action button is present.
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
