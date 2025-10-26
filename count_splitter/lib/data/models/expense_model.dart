import '../../domain/entities/expense.dart';

/// Data model for Expense with JSON serialization
/// Follows Open/Closed Principle - extends domain entity with serialization
class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.groupId,
    required super.description,
    required super.amount,
    required super.paidBy,
    required super.splitAmong,
    required super.splitType,
    super.customAmounts,
    required super.createdAt,
    super.updatedAt,
    super.isSettled,
  });

  /// Create from domain entity
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      groupId: expense.groupId,
      description: expense.description,
      amount: expense.amount,
      paidBy: expense.paidBy,
      splitAmong: expense.splitAmong,
      splitType: expense.splitType,
      customAmounts: expense.customAmounts,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
      isSettled: expense.isSettled,
    );
  }

  /// Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paidBy'] as String,
      splitAmong: List<String>.from(json['splitAmong'] as List),
      splitType: SplitType.values.firstWhere(
        (type) => type.name == json['splitType'],
      ),
      customAmounts: Map<String, double>.from(
        (json['customAmounts'] as Map<String, dynamic>? ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isSettled: json['isSettled'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'splitAmong': splitAmong,
      'splitType': splitType.name,
      'customAmounts': customAmounts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isSettled': isSettled,
    };
  }

  /// Create copy as model
  ExpenseModel copyWithModel({
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
    return ExpenseModel(
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
}