import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:expense_manager/models/recurring_expense.dart';
import 'recurring_expense_sheet_model.dart';

class RecurringExpenseSheet extends StackedView<RecurringExpenseSheetModel> {
  final Function(SheetResponse)? completer;
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
      padding: const EdgeInsets.all(20),
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
            request.title ?? 'Add Recurring Expense',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: viewModel.nameController,
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: viewModel.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: viewModel.amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<RecurringExpenseType>(
            value: viewModel.selectedType,
            decoration: const InputDecoration(
              labelText: 'Recurrence Type *',
              border: OutlineInputBorder(),
            ),
            items: RecurringExpenseType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.toString().split('.').last),
              );
            }).toList(),
            onChanged: viewModel.setType,
          ),
          if (viewModel.selectedType == RecurringExpenseType.custom)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextField(
                controller: viewModel.intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Interval (days) *',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => viewModel.selectDate(context, true),
                  child: Text(
                      'Start Date: ${viewModel.startDate?.toString().split(' ')[0] ?? 'Select'}'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () => viewModel.selectDate(context, false),
                  child: Text(
                      'End Date: ${viewModel.endDate?.toString().split(' ')[0] ?? 'Select'}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () =>
                    completer?.call(SheetResponse(confirmed: false)),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (viewModel.validateAndSave()) {
                    completer?.call(
                      SheetResponse(
                        confirmed: true,
                        data: viewModel.recurringExpense,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  RecurringExpenseSheetModel viewModelBuilder(BuildContext context) =>
      RecurringExpenseSheetModel();
}
