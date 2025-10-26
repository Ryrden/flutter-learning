import 'package:flutter_test/flutter_test.dart';
import 'package:count_splitter/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('should format currency correctly', () {
      expect(CurrencyFormatter.format(100.0), equals('\$100.00'));
      expect(CurrencyFormatter.format(1234.56), equals('\$1,234.56'));
      expect(CurrencyFormatter.format(0.99), equals('\$0.99'));
      expect(CurrencyFormatter.format(1000000.0), equals('\$1,000,000.00'));
    });

    test('should format currency with custom symbol', () {
      expect(CurrencyFormatter.formatWithSymbol(100.0, '€'), equals('€100.00'));
      expect(CurrencyFormatter.formatWithSymbol(1234.56, '£'), equals('£1,234.56'));
    });

    test('should parse currency strings correctly', () {
      expect(CurrencyFormatter.parse('\$100.00'), equals(100.0));
      expect(CurrencyFormatter.parse('\$1,234.56'), equals(1234.56));
      expect(CurrencyFormatter.parse('100'), equals(100.0));
      expect(CurrencyFormatter.parse('0.99'), equals(0.99));
      expect(CurrencyFormatter.parse('invalid'), isNull);
    });

    test('should format for input field correctly', () {
      expect(CurrencyFormatter.formatForInput(100.0), equals('100.00'));
      expect(CurrencyFormatter.formatForInput(0.5), equals('0.50'));
      expect(CurrencyFormatter.formatForInput(1234.567), equals('1234.57'));
    });

    test('should validate currency input correctly', () {
      expect(CurrencyFormatter.isValidAmount('100.00'), isTrue);
      expect(CurrencyFormatter.isValidAmount('0.01'), isTrue);
      expect(CurrencyFormatter.isValidAmount('999999.99'), isTrue);
      
      expect(CurrencyFormatter.isValidAmount('0'), isFalse);
      expect(CurrencyFormatter.isValidAmount('-100'), isFalse);
      expect(CurrencyFormatter.isValidAmount('1000000'), isFalse);
      expect(CurrencyFormatter.isValidAmount('invalid'), isFalse);
    });

    test('should format compact currency correctly', () {
      expect(CurrencyFormatter.formatCompact(1000.0), equals('\$1K'));
      expect(CurrencyFormatter.formatCompact(1500.0), equals('\$1.5K'));
      expect(CurrencyFormatter.formatCompact(1000000.0), equals('\$1M'));
      expect(CurrencyFormatter.formatCompact(100.0), equals('\$100'));
    });
  });
}