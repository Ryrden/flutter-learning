/// Enumeration for different expense splitting methods
/// Follows Open/Closed Principle - easy to extend with new split types
enum SplitType {
  equal,      // Split equally among all members
  custom,     // Custom amounts per member
  smart,      // Smart split based on financial profiles
}

/// Represents an individual expense within a group
/// Follows Single Responsibility Principle - handles expense data and calculations
class Expense {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> splitAmong;
  final SplitType splitType;
  final Map<String, double> customAmounts;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isSettled;

  const Expense({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
    required this.splitType,
    this.customAmounts = const {},
    required this.createdAt,
    this.updatedAt,
    this.isSettled = false,
  });

  /// Calculate equal split amount per person
  double get equalSplitAmount {
    if (splitAmong.isEmpty) return 0.0;
    return amount / splitAmong.length;
  }

  /// Check if expense has valid split amounts
  bool get hasValidSplit {
    switch (splitType) {
      case SplitType.equal:
        return splitAmong.isNotEmpty;
      case SplitType.custom:
        final totalCustomAmount = customAmounts.values.fold(0.0, (sum, amt) => sum + amt);
        return (totalCustomAmount - amount).abs() < 0.01; // Allow small floating point differences
      case SplitType.smart:
        return splitAmong.isNotEmpty;
    }
  }

  /// Get amount owed by specific user
  double getAmountOwedBy(String userId) {
    if (!splitAmong.contains(userId)) return 0.0;
    if (userId == paidBy) return 0.0; // Payer doesn't owe themselves

    switch (splitType) {
      case SplitType.equal:
        return equalSplitAmount;
      case SplitType.custom:
        return customAmounts[userId] ?? 0.0;
      case SplitType.smart:
        return customAmounts[userId] ?? equalSplitAmount;
    }
  }

  /// Check if this expense triggers the 75% warning for any user
  bool hasPaymentWarning() {
    final warningThreshold = amount * 0.75;
    
    for (final userId in splitAmong) {
      if (getAmountOwedBy(userId) > warningThreshold) {
        return true;
      }
    }
    return false;
  }

  Expense copyWith({
    String? id,
    String? groupId,
    String? description,
    double? amount,
    String? paidBy,
    List<String>? splitAmong,
    SplitType? splitType,
    Map<String, double>? customAmounts,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSettled,
  }) {
    return Expense(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      splitAmong: splitAmong ?? this.splitAmong,
      splitType: splitType ?? this.splitType,
      customAmounts: customAmounts ?? this.customAmounts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.groupId == groupId &&
        other.description == description &&
        other.amount == amount &&
        other.paidBy == paidBy &&
        _listEquals(other.splitAmong, splitAmong) &&
        other.splitType == splitType &&
        _mapEquals(other.customAmounts, customAmounts) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSettled == isSettled;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        groupId.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        paidBy.hashCode ^
        splitAmong.hashCode ^
        splitType.hashCode ^
        customAmounts.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSettled.hashCode;
  }

  @override
  String toString() {
    return 'Expense(id: $id, description: $description, amount: \$${amount.toStringAsFixed(2)}, splitType: $splitType)';
  }

  // Helper methods for equality comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }

  bool _mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}