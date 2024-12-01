import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:stacked/stacked.dart';

class CalenderSheetModel extends BaseViewModel {
  final _storageService = locator<StorageService>();

  int _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;
  List<int> _availableYears = [];
  List<Expense> _allExpenses = [];

  CalenderSheetModel({
    required int initialYear,
    int? initialMonth,
    int? initialDay,
  })  : _selectedYear = initialYear,
        _selectedMonth = initialMonth,
        _selectedDay = initialDay;

  int get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  int? get selectedDay => _selectedDay;
  List<int> get availableYears => _availableYears;

  int get daysInSelectedMonth {
    if (_selectedMonth == null) return 0;
    return DateTime(_selectedYear, _selectedMonth! + 1, 0).day;
  }

  Future<void> initialise() async {
    // final sampleData = Expense.generateSampleExpensesJson();
    final sampleData = await _storageService.getAllExpensesAsMap();
    _allExpenses = (sampleData['expenses'] as List)
        .map((e) => Expense.fromJson(e))
        .toList();

    // Get unique years from expenses
    _availableYears = _allExpenses.map((e) => e.date.year).toSet().toList()
      ..sort();

    notifyListeners();
  }

  void setSelectedYear(int year) {
    _selectedYear = year;
    _selectedMonth = null;
    _selectedDay = null;
    notifyListeners();
  }

  void setSelectedMonth(int? month) {
    _selectedMonth = month;
    _selectedDay = null;
    notifyListeners();
  }

  void setSelectedDay(int? day) {
    _selectedDay = day;
    notifyListeners();
  }

  int getExpenseCountForDay(int day) {
    if (_selectedMonth == null) return 0;

    return _allExpenses
        .where((expense) =>
            expense.date.year == _selectedYear &&
            expense.date.month == _selectedMonth &&
            expense.date.day == day)
        .length;
  }

  // int get currentSelectionExpenseCount {
  //   return _allExpenses.where((expense) {
  //     // Filter by year
  //     if (expense.date.year != _selectedYear) return false;

  //     // Filter by month if selected
  //     if (_selectedMonth != null && expense.date.month != _selectedMonth)
  //       return false;

  //     // Filter by day if selected
  //     if (_selectedDay != null && expense.date.day != _selectedDay)
  //       return false;

  //     return true;
  //   }).length;
  // }

  // String? get selectionWarningMessage {
  //   if (currentSelectionExpenseCount == 0) {
  //     if (_selectedDay != null) {
  //       return 'No expenses found for $_selectedDay ${_getMonthName(_selectedMonth!)} $_selectedYear';
  //     } else if (_selectedMonth != null) {
  //       return 'No expenses found for ${_getMonthName(_selectedMonth!)} $_selectedYear';
  //     } else {
  //       return 'No expenses found for $_selectedYear';
  //     }
  //   }
  //   return null;
  // }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  bool hasExpensesForYear(int year) {
    return _allExpenses.any((expense) => expense.date.year == year);
  }

  bool hasExpensesForMonth(int month) {
    return _allExpenses.any((expense) =>
        expense.date.year == _selectedYear && expense.date.month == month);
  }

  List<int> get availableMonthsInYear {
    return _allExpenses
        .where((expense) => expense.date.year == _selectedYear)
        .map((expense) => expense.date.month)
        .toSet()
        .toList()
      ..sort();
  }
}
