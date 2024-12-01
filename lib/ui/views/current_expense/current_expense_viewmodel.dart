import 'package:expense_manager/app/app.bottomsheets.dart';
import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/services/app_authentication_service.dart';
import 'package:expense_manager/services/drive_backup_service.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:expense_manager/ui/bottom_sheets/add_edit_expense/add_edit_expense_sheet.dart';
import 'package:expense_manager/ui/bottom_sheets/edit_delete/edit_delete_sheet.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:stacked_services/stacked_services.dart';

class CurrentExpenseViewModel extends BaseViewModel {
  final _storageService = locator<StorageService>();
  final _driveService = locator<DriveBackupService>();
  final _authService = locator<AppAuthenticationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _routerService = locator<RouterService>();
  List<Expense> _currentMonthExpenses = [];
  List<String> _expenseNames = [];

  List<Expense> get currentMonthExpenses => _currentMonthExpenses;
  List<String> get expenseNames => _expenseNames;
  bool get hasExpenses => _currentMonthExpenses.isNotEmpty;

  double get totalExpenses {
    return _currentMonthExpenses.fold(
      0,
      (total, expense) => total + expense.amount,
    );
  }

  Future<void> initialize() async {
    setBusy(true);
    _loadExpenses();
    await _loadExpenseNames();
    setBusy(false);
  }

  void _loadExpenses() {
    _currentMonthExpenses = _storageService.getCurrentMonthExpenses();
    notifyListeners();
  }

  Future<void> _loadExpenseNames() async {
    _expenseNames = await _storageService.getExpenseNames();
    notifyListeners();
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

    _loadExpenses();
  }

  Future<void> showAddExpenseBottomSheet({Expense? expense}) async {
    final SheetResponse? response = await _bottomSheetService.showCustomSheet(
      enableDrag: true,
      isScrollControlled: true,
      variant: BottomSheetType.addEditExpense,
      data: AddEditExpenseSheetArgs(expense: expense),
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

  String fetchCurrentMonthName() {
    return "(${DateFormat('MMMM yyyy').format(DateTime.now())})";
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
        _loadExpenses();
      } else {
        showAddExpenseBottomSheet(expense: deletedExpense.expense);
      }
    }
  }

  Future<void> updateExpense({required Expense? expense}) async {
    await _storageService.updateExpense(expense: expense);
    _loadExpenses();
  }
}
