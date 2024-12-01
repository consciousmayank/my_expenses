import 'package:expense_manager/extensions/textstyles_extension.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'current_expense_viewmodel.dart';

class CurrentExpenseViewMobile
    extends ViewModelWidget<CurrentExpenseViewModel> {
  const CurrentExpenseViewMobile({super.key});

  @override
  Widget build(BuildContext context, CurrentExpenseViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expenses', style: const TextStyle().heading24),
            Text(viewModel.fetchCurrentMonthName(),
                style: const TextStyle().body16),
          ],
        ),
        actions: [
          if (viewModel.hasExpenses)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddExpenseBottomSheet(context, viewModel),
            ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, CurrentExpenseViewModel viewModel) {
    if (!viewModel.hasExpenses) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No expenses added yet'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddExpenseBottomSheet(context, viewModel),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: viewModel.currentMonthExpenses.length,
          itemBuilder: (context, index) {
            final expense = viewModel.currentMonthExpenses[index];
            return ListTile(
              title: Text(expense.name),
              subtitle: expense.description != null
                  ? Text(expense.description!)
                  : null,
              trailing: Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              leading: expense.isRecurring
                  ? const Icon(Icons.repeat, color: Colors.blue)
                  : null,
              onLongPress: () =>
                  viewModel.showEditDeleteExpenseBottomSheet(expense),
            );
          },
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${viewModel.totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddExpenseBottomSheet(
      BuildContext context, CurrentExpenseViewModel viewModel) {
    viewModel.showAddExpenseBottomSheet();
  }
}
