import 'package:expense_manager/extensions/textstyles_extension.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/ui/common/app_colors.dart';
import 'package:expense_manager/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'recurring_expense_sheet_model.dart';

class RecurringExpenseSheet extends StackedView<RecurringExpenseSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const RecurringExpenseSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    RecurringExpenseSheetModel viewModel,
    Widget? child,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            request.title ?? 'Add Recurring Expense',
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
          verticalSpaceMedium,
          Text(
              'Recurring expense is the expense which you have to pay till a certain date. Like Emis or Loans.',
              style: TextStyle().heading18),
          SizedBox(height: 8),
          Text(
            'Flow to add a recurring expense',
            style: TextStyle().body16,
          ),
          SizedBox(height: 8),
          SizedBox(height: 8),
          Text(
            '1. Add an expense',
            style: TextStyle().body16,
          ),
          SizedBox(height: 8),
          Text(
            '2. Select a date at which this expense will be added every month.',
            style: TextStyle().heading18.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text('3. Select an end date for the recurring expense. After this date the expense will not be added.',
              style: TextStyle().heading18.copyWith(color: Colors.grey)),
          verticalSpaceLarge,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  completer?.call(SheetResponse(confirmed: false));
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  completer?.call(SheetResponse(confirmed: true));
                },
                child: const Text('Continue'),
              ),
            ],
          ),
          verticalSpaceMedium,
        ],
      ),
    );
  }

  @override
  RecurringExpenseSheetModel viewModelBuilder(BuildContext context) =>
      RecurringExpenseSheetModel();
}
