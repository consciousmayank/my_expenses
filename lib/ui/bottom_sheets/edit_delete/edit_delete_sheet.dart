import 'package:expense_manager/extensions/textstyles_extension.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/ui/common/app_colors.dart';
import 'package:expense_manager/ui/common/ui_helpers.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'edit_delete_sheet_model.dart';

class EditDeleteSheet extends StackedView<EditDeleteSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const EditDeleteSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    EditDeleteSheetModel viewModel,
    Widget? child,
  ) {
    final EditDeleteExpenseSheetArgs args =
        request.data as EditDeleteExpenseSheetArgs;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          verticalSpaceSmall,
          Text(
            request.title ?? '',
            style: const TextStyle().heading20,
          ),
          verticalSpaceMedium,
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize:
                        const Size.fromHeight(kToolbarHeight), // Added height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle()
                        .button16
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    completer?.call(SheetResponse(
                      confirmed: true,
                      data: EditDeleteExpenseSheetResponse.edit(
                          expense: args.expense),
                    ));
                  },
                  child: const Text('Edit Expense'),
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                flex: 1,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize:
                        const Size.fromHeight(kToolbarHeight), // Added height
                    textStyle: const TextStyle()
                        .button16
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    completer?.call(SheetResponse(
                      confirmed: true,
                      data: EditDeleteExpenseSheetResponse.delete(
                          expense: args.expense),
                    ));
                  },
                  child: const Text('Delete Expense'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  EditDeleteSheetModel viewModelBuilder(BuildContext context) =>
      EditDeleteSheetModel();
}

class EditDeleteExpenseSheetArgs {
  final Expense expense;
  const EditDeleteExpenseSheetArgs({required this.expense});
}

class EditDeleteExpenseSheetResponse {
  final Expense? expense;
  final EditDeleteExpenseSheetOption option;
  const EditDeleteExpenseSheetResponse.edit({required this.expense})
      : option = EditDeleteExpenseSheetOption.edit;
  const EditDeleteExpenseSheetResponse.delete({required this.expense})
      : option = EditDeleteExpenseSheetOption.delete;
}

enum EditDeleteExpenseSheetOption {
  edit,
  delete,
}
