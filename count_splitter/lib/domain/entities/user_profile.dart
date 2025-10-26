import 'package:equatable/equatable.dart';

/// Represents a user's financial profile for smart expense splitting
/// Follows Single Responsibility Principle - only handles financial data
class UserProfile extends Equatable {
  final double monthlyIncome;
  final double monthlyExpenses;
  final double monthlyFunBudget;
  final bool allowSmartSplit;
  final bool showAmountsToGroup;

  const UserProfile({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.monthlyFunBudget,
    this.allowSmartSplit = true,
    this.showAmountsToGroup = false,
  });

  /// Calculate available disposable income for social activities
  double get disposableIncome => monthlyIncome - monthlyExpenses;

  /// Check if user has enough fun budget
  bool get hasValidFunBudget => monthlyFunBudget <= disposableIncome;

  /// Calculate what percentage of fun budget an amount represents
  double calculateFunBudgetPercentage(double amount) {
    if (monthlyFunBudget <= 0) return 0;
    return amount / monthlyFunBudget;
  }

  UserProfile copyWith({
    double? monthlyIncome,
    double? monthlyExpenses,
    double? monthlyFunBudget,
    bool? allowSmartSplit,
    bool? showAmountsToGroup,
  }) {
    return UserProfile(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      monthlyFunBudget: monthlyFunBudget ?? this.monthlyFunBudget,
      allowSmartSplit: allowSmartSplit ?? this.allowSmartSplit,
      showAmountsToGroup: showAmountsToGroup ?? this.showAmountsToGroup,
    );
  }

  @override
  List<Object?> get props => [
        monthlyIncome,
        monthlyExpenses,
        monthlyFunBudget,
        allowSmartSplit,
        showAmountsToGroup,
      ];
}