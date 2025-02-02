import 'dart:convert';

import 'package:expense_manager/app/app.bottomsheets.dart';
import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/app/app.router.dart';
import 'package:expense_manager/extensions/date_format_extension.dart';
import 'package:expense_manager/models/logged_in_user.dart';
import 'package:expense_manager/services/drive_backup_service.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:expense_manager/ui/bottom_sheets/add_edit_expense/add_edit_expense_sheet.dart';
import 'package:expense_manager/ui/bottom_sheets/edit_delete/edit_delete_sheet.dart';
import 'package:stacked/stacked.dart';
import '../../../models/expense.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../bottom_sheets/calender/calender_sheet.dart';

class AllExpensesViewModel extends BaseViewModel {
  final DriveBackupService _driveBackupService = locator<DriveBackupService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final RouterService _routerService = locator<RouterService>();
  String? _errorMessage;
  LoggedInUser? loggedInUser;
  List<Expense> _currentMonthExpenses = [];
  List<String> _expenseNames = [];

  final _storageService = locator<StorageService>();
  final _bottomSheetService = locator<BottomSheetService>();

  int _selectedYear = DateTime.now().year;
  int? _selectedMonth = DateTime.now().month;
  int? _selectedDay = DateTime.now().day;

  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];

  List<Expense> get filteredExpenses => _filteredExpenses;

  int get selectedYear => _selectedYear;
  int? get selectedMonth => _selectedMonth;
  int? get selectedDay => _selectedDay;

  String get selectedPeriodText {
    if (_selectedDay != null) {
      return '$_selectedDay ${_getMonthName(_selectedMonth!)} $_selectedYear';
    } else if (_selectedMonth != null) {
      return '${_getMonthName(_selectedMonth!)} $_selectedYear';
    } else {
      return '$_selectedYear';
    }
  }

  Future<void> fetchLoggedInUser() async {
    loggedInUser = await _storageService.getLoggedInUser();
    notifyListeners();
  }

  int get daysInSelectedMonth {
    if (_selectedMonth == null) return 0;
    return DateTime(_selectedYear, _selectedMonth! + 1, 0).day;
  }

  List<int> _availableYears = [];
  List<int> get availableYears => _availableYears;

  // Initialize the data
  Future<void> initialise() async {
    await fetchLoggedInUser();
    // final sampleData = Expense.generateSampleExpensesJson();
    final sampleData = await _storageService.getAllExpensesAsMap();
    _allExpenses = (sampleData['expenses'] as List)
        .map((e) => Expense.fromJson(e))
        .toList();

    // Get unique years from expenses
    _availableYears = _allExpenses.map((e) => e.date.year).toSet().toList()
      ..sort();

    // Set initial year to most recent available year
    if (_availableYears.isNotEmpty) {
      _selectedYear = _availableYears.last;
    }

    _filterExpenses();
  }

  void _filterExpenses() {
    _filteredExpenses = _allExpenses.where((expense) {
      // Filter by year
      if (expense.date.year != _selectedYear) return false;

      // Filter by month if selected
      if (_selectedMonth != null && expense.date.month != _selectedMonth) {
        return false;
      }

      // Filter by day if selected
      if (_selectedDay != null && expense.date.day != _selectedDay) {
        return false;
      }

      return true;
    }).toList();
    notifyListeners();
  }

  void setSelectedYear(int year) {
    _selectedYear = year;
    _selectedMonth = null; // Clear month and day selections
    _selectedDay = null;
    _filterExpenses();
  }

  void setSelectedMonth(int? month) {
    _selectedMonth = month;
    _selectedDay = null; // Clear day selection
    _filterExpenses();
  }

  void setSelectedDay(int? day) {
    _selectedDay = day;
    _filterExpenses();
  }

  void clearMonthSelection() {
    _selectedMonth = null;
    _selectedDay = null;
    _filterExpenses();
  }

  void clearDaySelection() {
    _selectedDay = null;
    _filterExpenses();
  }

  // Get the count of expenses for a specific day
  int getExpenseCountForDay(int day) {
    return _allExpenses
        .where((expense) =>
            expense.date.year == _selectedYear &&
            expense.date.month == _selectedMonth &&
            expense.date.day == day)
        .length;
  }

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

  double get totalFilteredAmount {
    return _filteredExpenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  Future<void> showCalendarSheet() async {
    final response = await _bottomSheetService.showCustomSheet(
      isScrollControlled: true,
      variant: BottomSheetType.calender,
      title: 'Select Date',
      data: {
        'selectedYear': _selectedYear,
        'selectedMonth': _selectedMonth,
        'selectedDay': _selectedDay,
      },
    );

    if (response?.confirmed == true && response?.data is DateSelection) {
      final dateSelection = response!.data as DateSelection;
      _selectedYear = dateSelection.year;
      _selectedMonth = dateSelection.month;
      _selectedDay = dateSelection.day;
      _filterExpenses();
    }
  }

  void backupToGoogleDrive() async {
    setBusy(true);
    _errorMessage = null;
    try {
      final expenses = await _storageService.getAllExpenses();

      final backupContent = json.encode({
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'backupDate': DateTime.now().toFormattedString(),
        'version': '1.0',
      });

      final fileId = await _driveBackupService.uploadFile(
        accessToken: loggedInUser!.accessToken!,
        fileName: 'expense_manager_backup.json',
        content: backupContent,
      );

      _snackbarService.showSnackbar(
        message: 'Backup successful',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _errorMessage = e.toString();
      _snackbarService.showSnackbar(
        message: 'Backup failed: $_errorMessage',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  void restoreFromGoogleDrive() async {
    setBusy(true);
    _errorMessage = null;
    try {
      final result = await _driveBackupService.readFileByName(
        accessToken: loggedInUser!.accessToken!,
        fileName: 'expense_manager_backup.json',
      );

      if (result['content'] == null) {
        throw Exception('Backup file not found on Google Drive');
      }

      final Map<String, dynamic> backupData = json.decode(result['content']!);
      final List<dynamic> expensesJson = backupData['expenses'];

      final expenses =
          expensesJson.map((json) => Expense.fromJson(json)).toList();

      // Save to local storage
      await _storageService.restoreExpenses(expenses);

      _snackbarService.showSnackbar(
        message: 'Restored ${expenses.length} expenses successfully',
        duration: const Duration(seconds: 3),
      );
      initialise();
    } catch (e) {
      _errorMessage = e.toString();
      _snackbarService.showSnackbar(
        message: 'Restore failed: $_errorMessage',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  void logout() async {
    setBusy(true);
    await _storageService.logout();
    await _driveBackupService.logout(accessToken: loggedInUser!.accessToken!);
    await _routerService.replaceWithLoginView();
  }

  Future<void> showEditDeleteExpenseBottomSheet(Expense expense) async {
    final SheetResponse? response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.editDelete,
      title: 'Choose an option',
      description: 'You can edit or delete the expense',
      data: EditDeleteExpenseSheetArgs(
        expense: expense,
      ),
    );

    if (response != null && response.confirmed) {
      EditDeleteExpenseSheetResponse deletedExpense = response.data;
      if (deletedExpense.option == EditDeleteExpenseSheetOption.delete) {
        _storageService.deleteExpense(deletedExpense.expense!);
        initialise();
      } else {
        showAddExpenseBottomSheet(expense: deletedExpense.expense);
      }
    }
  }

  Future<void> updateExpense({required Expense? expense}) async {
    await _storageService.updateExpense(expense: expense);
    initialise();
  }

  Future<void> showAddExpenseBottomSheet({Expense? expense}) async {
    if (_selectedDay == null || _selectedMonth == null) {
      SheetResponse? dateErrorResponse =
          await _bottomSheetService.showBottomSheet(
        title: "Notice !!",
        description: "To add an expense, you need to select a date first.",
        confirmButtonTitle: "Select Date",
        cancelButtonTitle: "Cancel",
      );

      if (dateErrorResponse?.confirmed == true) {
        showCalendarSheet().then((value) {
          showAddExpenseBottomSheet(expense: expense);  
        });
      }

    } else {
      final SheetResponse? response = await _bottomSheetService.showCustomSheet(
        enableDrag: true,
        isScrollControlled: true,
        variant: BottomSheetType.addEditExpense,
        data: AddEditExpenseSheetArgs(
          expense: expense,
          date: _selectedMonth != null && _selectedDay != null
              ? DateTime(_selectedYear, _selectedMonth!, _selectedDay!)
              : expense?.date,
        ),
      );

      if (response != null && response.confirmed) {
        AddEditExpenseSheetResponse addedExpense = response.data;
        if (expense == null) {
          await addExpense(expense: addedExpense.expense);
        } else {
          await updateExpense(expense: addedExpense.expense);
        }
      }
    }
  }

  Future<void> addExpense({required Expense? expense}) async {
    if (expense == null) return;
    await _storageService.saveExpense(expense: expense);

    // Backup to Google Drive if user is signed in
    // final accessToken = await _authService.getAccessToken();
    // if (accessToken != null) {
    //   final expenses = await _storageService.getAllExpenses();
    //   final recurringExpenses = await _storageService.getRecurringExpenses();
    //   await _driveService.backupData(accessToken, expenses, recurringExpenses);
    // }

    initialise();
  }

  void deleteExpense(Expense expense) {
    _storageService.deleteExpense(expense);
    initialise();
  }
}
