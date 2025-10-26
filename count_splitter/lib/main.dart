import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/providers/group_provider.dart';
import 'injection_container.dart' as di;
import 'domain/usecases/calculate_smart_split.dart';
import 'domain/usecases/create_expense.dart';
import 'domain/usecases/create_group.dart';
import 'domain/usecases/get_groups.dart';
import 'domain/repositories/expense_repository.dart';
import 'domain/repositories/group_repository.dart';
import 'data/repositories/local_expense_repository.dart';
import 'data/repositories/local_group_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await _initDependencies();
  
  runApp(const CountSplitterApp());
}

/// Initialize all dependencies following Dependency Inversion Principle
Future<void> _initDependencies() async {
  // Register repositories
  di.getIt.registerLazySingleton<ExpenseRepository>(
    () => LocalExpenseRepository(),
  );
  
  di.getIt.registerLazySingleton<GroupRepository>(
    () => LocalGroupRepository(),
  );
  
  // Register use cases
  di.getIt.registerLazySingleton<CalculateSmartSplit>(
    () => CalculateSmartSplit(),
  );
  
  di.getIt.registerLazySingleton<CreateExpense>(
    () => CreateExpense(di.getIt.get<ExpenseRepository>()),
  );
  
  di.getIt.registerLazySingleton<CreateGroup>(
    () => CreateGroup(di.getIt.get<GroupRepository>()),
  );
  
  di.getIt.registerLazySingleton<GetGroupsForUser>(
    () => GetGroupsForUser(di.getIt.get<GroupRepository>()),
  );
  
  di.getIt.registerLazySingleton<AddMemberToGroup>(
    () => AddMemberToGroup(di.getIt.get<GroupRepository>()),
  );
  
  di.getIt.registerLazySingleton<GetGroupById>(
    () => GetGroupById(di.getIt.get<GroupRepository>()),
  );
  
  // TODO: Register Firebase repositories when Firebase is configured
}

class CountSplitterApp extends StatelessWidget {
  const CountSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GroupProvider(
            createGroup: di.getIt.get<CreateGroup>(),
            getGroupsForUser: di.getIt.get<GetGroupsForUser>(),
            addMemberToGroup: di.getIt.get<AddMemberToGroup>(),
            getGroupById: di.getIt.get<GetGroupById>(),
          ),
        ),
      ],
      child: MaterialApp(
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
        home: const MainPage(),
      ),
    );
  }
}

