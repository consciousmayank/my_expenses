import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:expense_manager/ui/bottom_sheets/add_edit_expense/add_edit_expense_sheet.form.dart';
import 'package:expense_manager/ui/common/app_strings.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class AddEditExpenseSheetModel extends FormViewModel {
  String? _formError;

  String? get formError => _formError;

  void setFormError(String? error) {
    _formError = error;
    notifyListeners();
  }

  bool _enteringNewExpense = false;

  final _storageService = locator<StorageService>();

  List<String> _filteredExpenseNames = [];

  List<String> get filteredExpenseNames => _filteredExpenseNames;

  List<String> _expenseNames = [];

  bool get enteringNewExpense => _enteringNewExpense;

  set selectedExpenseName(String? selectedExpenseName) {
    _enteringNewExpense = selectedExpenseName == ksNewExpense;
    if (!_enteringNewExpense) {
      nameValue = selectedExpenseName;
      descriptionValue = '';
      amountValue = '';
    } else {
      nameValue = '';
      descriptionValue = '';
      amountValue = '';
    }
    notifyListeners();
  }

  List<String> get expenseNames => _expenseNames;

  Future<void> loadExpenseNames() async {
    _expenseNames = await _storageService.getExpenseNames();
    notifyListeners();
  }

  void updateFilteredExpenseNames(String value) {
    _filteredExpenseNames = _expenseNames
        .where((name) => name.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  String? validate() {
    setFormError(null);
    if (nameValue == null || nameValue!.isEmpty) {
      setFormError('${formError ?? ''} $ksNameRequired.');
    }

    if (amountValue == null || amountValue!.isEmpty) {
      setFormError('${formError ?? ''} $ksAmountRequired.');
    }

    final amount = double.parse(amountValue!);
    if (amount <= 0) {
      setFormError('${formError ?? ''} $ksAmountMustBeGreaterThanZero.');
    }
    return formError;
  }

  void showError(String error) {
    locator<SnackbarService>().showSnackbar(message: error);
  }
}
