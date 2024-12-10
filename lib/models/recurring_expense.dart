import 'package:expense_manager/ui/common/app_constants.dart';
import 'package:hive/hive.dart';

part 'recurring_expense.g.dart';

@HiveType(typeId: HiveTypeIdRecurringExpenseType)
enum RecurringExpenseType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  quarterly,
  @HiveField(4)
  annually,
  @HiveField(5)
  custom
}

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

  @HiveField(5)
  final RecurringExpenseType type;

  @HiveField(6)
  final int? customIntervalDays;

  @HiveField(7)
  final String? id;

  RecurringExpense({
    required this.name,
    this.description,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.customIntervalDays,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.toString(),
      'customIntervalDays': customIntervalDays,
      'id': id,
    };
  }

  factory RecurringExpense.fromJson(Map<String, dynamic> json) {
    return RecurringExpense(
      name: json['name'] as String,
      description: json['description'] as String?,
      amount:
          json['amount'] is int ? json['amount'].toDouble() : json['amount'],
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      type: RecurringExpenseType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      customIntervalDays: json['customIntervalDays'] as int?,
      id: json['id'] as String?,
    );
  }

  List<DateTime> getOccurrences() {
    List<DateTime> occurrences = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      occurrences.add(currentDate);
      currentDate = _getNextOccurrence(currentDate);
    }

    return occurrences;
  }

  DateTime _getNextOccurrence(DateTime current) {
    switch (type) {
      case RecurringExpenseType.daily:
        return current.add(const Duration(days: 1));
      case RecurringExpenseType.weekly:
        return current.add(const Duration(days: 7));
      case RecurringExpenseType.monthly:
        return DateTime(current.year, current.month + 1, current.day);
      case RecurringExpenseType.quarterly:
        return DateTime(current.year, current.month + 3, current.day);
      case RecurringExpenseType.annually:
        return DateTime(current.year + 1, current.month, current.day);
      case RecurringExpenseType.custom:
        return current.add(Duration(days: customIntervalDays ?? 1));
    }
  }

  RecurringExpense copyWith({
    String? name,
    String? description,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    RecurringExpenseType? type,
    int? customIntervalDays,
    String? id,
  }) {
    return RecurringExpense(
      name: name ?? this.name,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      customIntervalDays: customIntervalDays ?? this.customIntervalDays,
      id: id ?? this.id,
    );
  }
}
