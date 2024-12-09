import 'dart:convert';

import 'package:expense_manager/ui/common/app_constants.dart';
import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: HiveTypeIdExpense)
class Expense extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool isRecurring;

  @HiveField(5)
  final String? id;

  Expense({
    required this.name,
    this.description,
    required this.amount,
    required this.date,
    this.isRecurring = false,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'key': id,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: json['amount'] is int ? json['amount'].toDouble() : json['amount'],
      date: DateTime.parse(json['date'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      id: json['key'] as String?,
    );
  }

  static Expense fromString(String expenseStr) {
    return Expense.fromJson(json.decode(expenseStr));
  }

  Expense copyWith(
      {String? id,
      String? name,
      String? description,
      double? amount,
      DateTime? date,
      bool? isRecurring}) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  static Map<String, dynamic> generateSampleExpensesJson() {
    final List<Map<String, dynamic>> expenses = [];

    for (int year = 2021; year <= 2026; year++) {
      for (int month = 1; month <= 12; month++) {
        final daysInMonth = DateTime(year, month + 1, 0).day;

        for (int day = 1; day <= daysInMonth; day++) {
          final entriesCount = day % 2 == 0 ? 20 : 30;

          for (int entry = 0; entry < entriesCount; entry++) {
            final expense = Expense(
              name: 'Expense ${entry + 1}',
              description: 'Sample expense for $year-$month-$day',
              amount: (entry + 1) * 10.0,
              date: DateTime(year, month, day),
              isRecurring: entry % 5 == 0,
              id: '${year}${month.toString().padLeft(2, '0')}${day.toString().padLeft(2, '0')}_$entry',
            );

            expenses.add(expense.toJson());
          }
        }
      }
    }

    return {
      'expenses': expenses,
      'totalCount': expenses.length,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  static String generateSampleExpensesJsonString() {
    return json.encode(generateSampleExpensesJson());
  }
}
