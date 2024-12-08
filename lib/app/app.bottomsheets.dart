// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/add_edit_expense/add_edit_expense_sheet.dart';
import '../ui/bottom_sheets/calender/calender_sheet.dart';
import '../ui/bottom_sheets/edit_delete/edit_delete_sheet.dart';
import '../ui/bottom_sheets/my_account/my_account_sheet.dart';
import '../ui/bottom_sheets/notice/notice_sheet.dart';
import '../ui/bottom_sheets/recurring_expense/recurring_expense_sheet.dart';
import '../ui/bottom_sheets/view/view_sheet.dart';

enum BottomSheetType {
  notice,
  view,
  editDelete,
  addEditExpense,
  calender,
  myAccount,
  recurringExpense,
}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.notice: (context, request, completer) =>
        NoticeSheet(request: request, completer: completer),
    BottomSheetType.view: (context, request, completer) =>
        ViewSheet(request: request, completer: completer),
    BottomSheetType.editDelete: (context, request, completer) =>
        EditDeleteSheet(request: request, completer: completer),
    BottomSheetType.addEditExpense: (context, request, completer) =>
        AddEditExpenseSheet(request: request, completer: completer),
    BottomSheetType.calender: (context, request, completer) =>
        CalenderSheet(request: request, completer: completer),
    BottomSheetType.myAccount: (context, request, completer) =>
        MyAccountSheet(request: request, completer: completer),
    BottomSheetType.recurringExpense: (context, request, completer) =>
        RecurringExpenseSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}
