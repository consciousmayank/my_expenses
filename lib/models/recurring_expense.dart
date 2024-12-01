import 'package:expense_manager/ui/common/app_constants.dart';
import 'package:hive/hive.dart';

part 'recurring_expense.g.dart';

@HiveType(typeId: HiveTypeIdRecurringExpense)
class RecurringExpense extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime startDate;

  @HiveField(4)
  final DateTime endDate;

  RecurringExpense({
    required this.name,
    this.description,
    required this.amount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      name: json['name'] as String,
      description: json['description'] as String?,
      amount: json['amount'] as double,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  bool isActiveForDate(DateTime date) {
    return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1)));
  }
}
