import 'dart:convert';

import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/models/logged_in_user.dart';
import 'package:expense_manager/services/drive_backup_service.dart';
import 'package:expense_manager/ui/common/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/recurring_expense.dart';

class StorageService implements InitializableDependency {
  final String expensesBox = 'expenses';
  final String recurringExpensesBox = 'recurringExpenses';
  final String expenseNamesBox = 'expenseNames';
  final String loggedInUserBox = 'loggedInUser';
  final String _preferencesKey = 'preferencesKey';
  // final String _isUserLoggedInKey = 'isUserLoggedIn';
  late List<int> _key;
  late Box<LoggedInUser> _loggedInUserBox;
  late Box<Expense> _expensesBox;
  late Box<RecurringExpense> _recurringExpensesBox;
  late Box<String> _expenseNamesBox;

  final _uuid = const Uuid();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  @override
  Future<void> init() async {
    await _initializeHive();
  }

  Future<void> _initializeHive() async {
    String? keyString = await _secureStorage.read(key: _preferencesKey);

    if (keyString == null) {
      _key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _preferencesKey,
        value: base64UrlEncode(
          _key,
        ),
      );
    } else {
      _key = base64Url.decode(keyString);
    }

    if (!Hive.isAdapterRegistered(HiveTypeIdExpense)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIdRecurringExpense)) {
      Hive.registerAdapter(RecurringExpenseAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIdLoggedInUser)) {
      Hive.registerAdapter(LoggedInUserAdapter());
    }
    if (!Hive.isAdapterRegistered(HiveTypeIdRecurringExpenseType)) {
      Hive.registerAdapter(RecurringExpenseTypeAdapter());
    }

    await Hive.initFlutter();
    _expensesBox = await _openBox<Expense>(boxName: expensesBox);
    _recurringExpensesBox =
        await _openBox<RecurringExpense>(boxName: recurringExpensesBox);
    _expenseNamesBox = await _openBox<String>(boxName: expenseNamesBox);
    _loggedInUserBox = await _openBox<LoggedInUser>(boxName: loggedInUserBox);
  }

  Future<void> saveExpense(
      {required Expense expense, bool isBackup = false}) async {
    expense = expense.copyWith(id: _uuid.v4());
    await _expensesBox.put(expense.id, expense);

    // Save expense name for autocomplete
    if (!_expenseNamesBox.values.contains(expense.name)) {
      await _expenseNamesBox.add(expense.name);
    }
  }

  Future<void> restoreExpenses(List<Expense> expenses) async {
    for (var expense in expenses) {
      await saveExpense(expense: expense, isBackup: true);
    }
  }

  List<Expense> getCurrentMonthExpenses() {
    final now = DateTime.now();
    return _expensesBox.values.where((expense) {
      return expense.date.month == now.month && expense.date.year == now.year;
    }).toList();
  }

  Future<List<Expense>> getAllExpenses() async {
    return _expensesBox.values.toList();
  }

  Future<List<String>> getExpenseNames() async {
    return _expenseNamesBox.values.toList();
  }

  Future<void> saveRecurringExpense(RecurringExpense expense) async {
    expense = expense.copyWith(id: _uuid.v4());
    await _recurringExpensesBox.put(expense.id, expense);

    // Generate and save individual expense instances
    final occurrences = expense.getOccurrences();
    print('Generated ${occurrences.length} occurrences for recurring expense');

    for (var date in occurrences) {
      final individualExpense = Expense(
        name: expense.name,
        description: expense.description,
        amount: expense.amount,
        date: date,
        isRecurring: true,
        id: '${expense.id}_${date.toIso8601String()}',
      );
      await saveExpense(expense: individualExpense);
    }
  }

  Future<void> updateRecurringExpense(RecurringExpense expense) async {
    // Delete old instances
    await deleteRecurringExpense(expense.id!);
    // Save updated recurring expense
    await saveRecurringExpense(expense);
  }

  Future<void> deleteRecurringExpense(String id) async {
    // Delete the recurring expense
    await _recurringExpensesBox.delete(id);

    // Delete all individual expense instances
    final expenses =
        _expensesBox.values.where((e) => e.id?.startsWith(id) ?? false);
    for (var expense in expenses) {
      deleteExpense(expense);
    }
  }

  Future<List<RecurringExpense>> getRecurringExpenses() async {
    return _recurringExpensesBox.values.toList();
  }

  saveLoggedInUser({required User user, required String? accessToken}) async {
    await _loggedInUserBox.put(
        user.uid,
        LoggedInUser(
          displayName: user.displayName,
          email: user.email ?? 'NA',
          id: user.uid,
          photoUrl: user.photoURL ?? 'NA',
          accessToken: accessToken,
        ));
  }

  Future<LoggedInUser?> getLoggedInUser() async {
    try {
      return _loggedInUserBox.values.firstOrNull;
    } catch (e) {
      return null;
    }
  }

  Future<Box<T>> _openBox<T>({required String boxName}) async {
    return await Hive.openBox<T>(boxName,
        encryptionCipher: HiveAesCipher(_key));
  }

  void deleteExpense(Expense expense) async {
    if (expense.isRecurring) {
      await deleteRecurringExpense(expense.id!);
    } else {
      await _expensesBox.delete(expense.id);
    }
  }

  Future<void> updateExpense({required Expense? expense}) async {
    if (expense == null) {
      return;
    }
    // Update expense in box with same id
    await _expensesBox.put(expense.id, expense);

    // Save expense name for autocomplete
    if (!_expenseNamesBox.values.contains(expense.name)) {
      await _expenseNamesBox.add(expense.name);
    }
  }

  Future<Map<String, dynamic>> getAllExpensesAsMap() async {
    final expenses = await getAllExpenses();
    return {
      'expenses': expenses.map((e) => e.toJson()).toList(),
    };
  }

  logout() async {
    await _loggedInUserBox.clear();
    await _expensesBox.clear();
    await _recurringExpensesBox.clear();
    await _expenseNamesBox.clear();
  }

  // Future<void> clearGuestData() async {
  //   final expensesBox = await Hive.openBox<Expense>(expensesBox);
  //   final recurringBox =
  //       await Hive.openBox<RecurringExpense>(recurringExpensesBox);
  //   final namesBox = await Hive.openBox<String>(expenseNamesBox);

  //   await expensesBox.clear();
  //   await recurringBox.clear();
  //   await namesBox.clear();
  // }

  Future<void> restoreFromBackup({
    required List<Expense> expenses,
    required List<RecurringExpense> recurringExpenses,
  }) async {
    // Clear existing data
    await _expensesBox.clear();
    await _recurringExpensesBox.clear();
    await _expenseNamesBox.clear();

    // Restore regular expenses
    for (var expense in expenses) {
      await saveExpense(expense: expense, isBackup: true);
    }

    // Restore recurring expenses
    for (var recurringExpense in recurringExpenses) {
      await saveRecurringExpense(recurringExpense);
    }
  }
}
