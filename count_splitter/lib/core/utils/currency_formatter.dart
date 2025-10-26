import 'package:intl/intl.dart';

/// Currency formatting utility
/// Follows Single Responsibility Principle - handles currency formatting only
class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Format amount as currency string
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount as currency string with custom symbol
  static String formatWithSymbol(double amount, String symbol) {
    final customFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: 2,
    );
    return customFormat.format(amount);
  }

  /// Parse currency string to double
  static double? parse(String currencyString) {
    try {
      // Remove currency symbol and spaces, then parse
      final cleanString = currencyString
          .replaceAll(RegExp(r'[^\d.-]'), '')
          .trim();
      return double.tryParse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Format amount for input field (no currency symbol)
  static String formatForInput(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Validate currency input
  static bool isValidAmount(String input) {
    final amount = parse(input);
    return amount != null && amount > 0 && amount <= 999999.99;
  }

  /// Format amount compactly (e.g., $1.2K, $1.5M)
  static String formatCompact(double amount) {
    final compactFormat = NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 1,
    );
    return compactFormat.format(amount);
  }
}