/// Application constants
/// Follows Single Responsibility Principle - centralized configuration
class AppConstants {
  // Expense splitting constants
  static const double warningThreshold = 0.75; // 75%
  static const double minExpenseAmount = 0.01;
  static const double maxExpenseAmount = 999999.99;
  
  // User profile constraints
  static const double minMonthlyIncome = 0.0;
  static const double maxMonthlyIncome = 999999.99;
  static const double minMonthlyExpenses = 0.0;
  static const double maxFunBudget = 999999.99;
  
  // Group constraints
  static const int maxGroupMembers = 50;
  static const int minGroupMembers = 2;
  static const int maxGroupNameLength = 100;
  static const int maxGroupDescriptionLength = 500;
  
  // User constraints
  static const int maxUserNameLength = 50;
  static const int minUserNameLength = 2;
  
  // Expense constraints
  static const int maxExpenseDescriptionLength = 200;
  static const int minExpenseDescriptionLength = 1;
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Currency
  static const String currencySymbol = '\$';
  static const int currencyDecimalPlaces = 2;
  
  // Error messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Private constructor to prevent instantiation
  AppConstants._();
}