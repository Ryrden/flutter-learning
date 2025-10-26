import 'package:flutter/material.dart';

/// Predefined expense categories with icons and colors
/// Follows Single Responsibility Principle - handles category data only
enum ExpenseCategory {
  food('Food & Dining', Icons.restaurant, Colors.orange),
  transport('Transport', Icons.directions_car, Colors.blue),
  entertainment('Entertainment', Icons.movie, Colors.purple),
  shopping('Shopping', Icons.shopping_bag, Colors.green),
  bills('Bills & Utilities', Icons.receipt_long, Colors.red),
  health('Health & Medical', Icons.local_hospital, Colors.teal),
  travel('Travel', Icons.flight, Colors.indigo),
  education('Education', Icons.school, Colors.amber),
  gifts('Gifts & Donations', Icons.card_giftcard, Colors.pink),
  other('Other', Icons.more_horiz, Colors.grey);

  const ExpenseCategory(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;

  /// Get category by name (case insensitive)
  static ExpenseCategory? fromString(String name) {
    try {
      return ExpenseCategory.values.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all categories as a list for dropdowns
  static List<ExpenseCategory> getAllCategories() {
    return ExpenseCategory.values;
  }

  /// Get popular categories (most commonly used)
  static List<ExpenseCategory> getPopularCategories() {
    return [
      ExpenseCategory.food,
      ExpenseCategory.transport,
      ExpenseCategory.entertainment,
      ExpenseCategory.shopping,
      ExpenseCategory.bills,
    ];
  }
}