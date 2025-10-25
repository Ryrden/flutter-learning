import '../../domain/entities/user_profile.dart';

/// Data model for UserProfile with JSON serialization
/// Follows Open/Closed Principle - extends domain entity with serialization
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.monthlyIncome,
    required super.monthlyExpenses,
    required super.monthlyFunBudget,
    super.allowSmartSplit,
    super.showAmountsToGroup,
  });

  /// Create from domain entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      monthlyIncome: profile.monthlyIncome,
      monthlyExpenses: profile.monthlyExpenses,
      monthlyFunBudget: profile.monthlyFunBudget,
      allowSmartSplit: profile.allowSmartSplit,
      showAmountsToGroup: profile.showAmountsToGroup,
    );
  }

  /// Create from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
      monthlyExpenses: (json['monthlyExpenses'] as num).toDouble(),
      monthlyFunBudget: (json['monthlyFunBudget'] as num).toDouble(),
      allowSmartSplit: json['allowSmartSplit'] as bool? ?? true,
      showAmountsToGroup: json['showAmountsToGroup'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'monthlyIncome': monthlyIncome,
      'monthlyExpenses': monthlyExpenses,
      'monthlyFunBudget': monthlyFunBudget,
      'allowSmartSplit': allowSmartSplit,
      'showAmountsToGroup': showAmountsToGroup,
    };
  }

  /// Create copy as model
  UserProfileModel copyWithModel({
    double? monthlyIncome,
    double? monthlyExpenses,
    double? monthlyFunBudget,
    bool? allowSmartSplit,
    bool? showAmountsToGroup,
  }) {
    return UserProfileModel(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      monthlyFunBudget: monthlyFunBudget ?? this.monthlyFunBudget,
      allowSmartSplit: allowSmartSplit ?? this.allowSmartSplit,
      showAmountsToGroup: showAmountsToGroup ?? this.showAmountsToGroup,
    );
  }
}