import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';
import 'injection_container.dart' as di;
import 'domain/usecases/calculate_smart_split.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await _initDependencies();
  
  runApp(const CountSplitterApp());
}

/// Initialize all dependencies following Dependency Inversion Principle
Future<void> _initDependencies() async {
  // Register use cases
  di.getIt.registerLazySingleton<CalculateSmartSplit>(
    () => CalculateSmartSplit(),
  );
  
  // TODO: Register repositories and data sources when implemented
  // di.getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl());
  // di.getIt.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl());
  // di.getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl());
}

class CountSplitterApp extends StatelessWidget {
  const CountSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Count Splitter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      home: const HomePage(),
    );
  }
}

