import 'dart:convert';

import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/extensions/date_format_extension.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/models/logged_in_user.dart';
import 'package:expense_manager/services/drive_backup_service.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:expense_manager/ui/views/login/login_view.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MyAccountViewModel extends BaseViewModel {
  final StorageService _storageService = locator<StorageService>();
  final DriveBackupService _driveBackupService = locator<DriveBackupService>();
  final SnackbarService _snackbarService = locator<SnackbarService>();
  final RouterService _routerService = locator<RouterService>();
  String? _errorMessage;
  LoggedInUser? loggedInUser;

  Future<void> fetchLoggedInUser() async {
    loggedInUser = await _storageService.getLoggedInUser();
    notifyListeners();
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
    await _storageService.logout();
    await _routerService.clearStackAndShowView(const LoginView());
  }

  void addRecurringExpense() {}
}
