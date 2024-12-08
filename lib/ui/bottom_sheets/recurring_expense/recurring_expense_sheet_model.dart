import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:expense_manager/models/recurring_expense.dart';

class RecurringExpenseSheetModel extends BaseViewModel {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final intervalController = TextEditingController();

  RecurringExpenseType _selectedType = RecurringExpenseType.monthly;
  DateTime? _startDate;
  DateTime? _endDate;

  RecurringExpenseType get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  void setType(RecurringExpenseType? type) {
    if (type != null) {
      _selectedType = type;
      notifyListeners();
    }
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStartDate) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
      notifyListeners();
    }
  }

  bool validateAndSave() {
    if (nameController.text.isEmpty ||
        amountController.text.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      return false;
    }

    if (_selectedType == RecurringExpenseType.custom &&
        intervalController.text.isEmpty) {
      return false;
    }

    return true;
  }

  RecurringExpense? get recurringExpense {
    if (!validateAndSave()) return null;

    return RecurringExpense(
      name: nameController.text,
      description: descriptionController.text,
      amount: double.parse(amountController.text),
      startDate: _startDate!,
      endDate: _endDate!,
      type: _selectedType,
      customIntervalDays: _selectedType == RecurringExpenseType.custom
          ? int.parse(intervalController.text)
          : null,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    intervalController.dispose();
    super.dispose();
  }
}
