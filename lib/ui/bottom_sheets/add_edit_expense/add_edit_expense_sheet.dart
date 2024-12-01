import 'package:expense_manager/extensions/textstyles_extension.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/ui/bottom_sheets/add_edit_expense/add_edit_expense_sheet.form.dart';
import 'package:expense_manager/ui/common/app_strings.dart';
import 'package:expense_manager/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

import 'add_edit_expense_sheet_model.dart';

@FormView(
  fields: [
    FormTextField(
      name: 'name',
    ),
    FormTextField(
      name: 'description',
    ),
    FormTextField(
      name: 'amount',
    ),
  ],
)
class AddEditExpenseSheet extends StackedView<AddEditExpenseSheetModel>
    with $AddEditExpenseSheet {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const AddEditExpenseSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    AddEditExpenseSheetModel viewModel,
    Widget? child,
  ) {
    AddEditExpenseSheetArgs args = request.data;

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
          Text(
            args.expense != null ? 'Edit Expense' : 'Add Expense',
            style: const TextStyle(fontWeight: FontWeight.normal).heading18,
          ),
          if (args.expense == null)
            if (!viewModel.enteringNewExpense)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  hintText: 'Select expense name',
                ),
                items: (viewModel.expenseNames + [ksNewExpense])
                    .map((name) => DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  viewModel.selectedExpenseName = value;
                  nameFocusNode.requestFocus();
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select an expense name';
                  }
                  return null;
                },
              ),
          const SizedBox(height: 16),
          if (viewModel.enteringNewExpense || args.expense != null)
            TextFormField(
              controller: nameController,
              focusNode: nameFocusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(descriptionFocusNode);
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9\s]+$')),
              ],
              decoration: InputDecoration(
                errorText: viewModel.nameValidationMessage,
                labelText: 'Expense Name *',
                hintText: 'Enter expense name',
              ),
            ),
          const SizedBox(height: 16),
          TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9\s]+$')),
            ],
            controller: descriptionController,
            focusNode: descriptionFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(amountFocusNode);
            },
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter description (optional)',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: amountController,
            focusNode: amountFocusNode,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              errorText: viewModel.amountValidationMessage,
              labelText: 'Amount *',
              hintText: 'Enter amount',
              prefixText: '₹ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid amount';
              }
              if (amount <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (viewModel.formError != null) const SizedBox(height: 24),
          if (viewModel.formError != null)
            Text(viewModel.formError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ).body16),
          if (viewModel.formError != null) const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final error = viewModel.validate();
              if (error == null) {
                final expense = Expense(
                  id: args.expense?.id,
                  name: nameController.text,
                  description: descriptionController.text,
                  amount: double.parse(amountController.text),
                  date: args.date ?? DateTime.now(),
                );
                completer?.call(SheetResponse(
                  confirmed: true,
                  data: AddEditExpenseSheetResponse(expense: expense),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Save Expense'),
          ),
        ],
      ),
    );
  }

  @override
  AddEditExpenseSheetModel viewModelBuilder(BuildContext context) =>
      AddEditExpenseSheetModel();

  @override
  void onViewModelReady(AddEditExpenseSheetModel viewModel) {
    syncFormWithViewModel(viewModel);
    AddEditExpenseSheetArgs args = request.data;

    if (args.expense == null) {
      viewModel.loadExpenseNames();
    } else {
      if (args.expense != null) {
        nameController.text = args.expense!.name;
        descriptionController.text = args.expense!.description ?? '';
        amountController.text = args.expense!.amount.toString();
      }
    }
  }

  @override
  void onDispose(AddEditExpenseSheetModel viewModel) {
    disposeForm();
    super.onDispose(viewModel);
  }
}

class AddEditExpenseSheetArgs {
  final Expense? expense;
  final DateTime? date;
  const AddEditExpenseSheetArgs({this.expense, this.date});
}

class AddEditExpenseSheetResponse {
  final Expense? expense;
  const AddEditExpenseSheetResponse({this.expense});
}
