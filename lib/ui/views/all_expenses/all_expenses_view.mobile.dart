import 'package:expense_manager/extensions/string_format_extensions.dart';
import 'package:expense_manager/extensions/textstyles_extension.dart';
import 'package:expense_manager/models/expense.dart';
import 'package:expense_manager/ui/common/app_strings.dart';
import 'package:expense_manager/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:stacked/stacked.dart';
import 'all_expenses_viewmodel.dart';

class AllExpensesViewMobile extends ViewModelWidget<AllExpensesViewModel> {
  const AllExpensesViewMobile({super.key});

  @override
  Widget build(BuildContext context, AllExpensesViewModel viewModel) {
    return Scaffold(
      appBar: AppBar(
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Expense For",
              style: const TextStyle().heading20,
            ),
            subtitle: Text(
              viewModel.selectedPeriodText,
              style: const TextStyle().body16,
            ),
          ),
        ),
        actions: [
          if (!viewModel.busy(ksBusyObjectFetchDataFromGdrive))
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'changeDate',
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Change Date'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'backupData',
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Backup Data'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'restoreData',
                  child: Row(
                    children: [
                      Icon(
                        Icons.cloud_download_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Restore Data'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'recurringExpenses',
                  child: Row(
                    children: [
                      Icon(
                        Icons.repeat_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Add Recurring Expenses'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                // Handle menu item selection
                switch (value) {
                  case 'changeDate':
                    viewModel.showCalendarSheet();
                    break;
                  case 'backupData':
                    viewModel.backupToGoogleDrive();
                    break;
                  case 'restoreData':
                    viewModel.restoreFromGoogleDrive();
                    break;
                  case 'logout':
                    viewModel.logout();
                    break;
                  case 'recurringExpenses':
                    viewModel.showAddRecurringExpenseBottomSheet();
                    break;
                }
              },
            ),
          horizontalSpaceTiny,
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : viewModel.filteredExpenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No expenses found for',
                        style: TextStyle(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.7),
                        ),
                      ),
                      if (viewModel.selectedDay != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          viewModel.selectedPeriodText,
                          style: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: viewModel.filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = viewModel.filteredExpenses[index];
                          final isRecurring = expense.isRecurring;

                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    viewModel.editExpense(expense);
                                  },
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.black38,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  ),
                                  icon: Icons.edit,
                                  label: 'Edit',
                                ),
                                const SizedBox(width: 2),
                                SlidableAction(
                                  onPressed: (context) {
                                    viewModel.deleteExpense(expense);
                                  },
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.black38,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isRecurring
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1)
                                    : null,
                                border: isRecurring
                                    ? Border(
                                        left: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 4,
                                        ),
                                      )
                                    : null,
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Text(expense.name),
                                    if (isRecurring) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.repeat,
                                        size: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: expense.description != null
                                    ? Text(expense.description!)
                                    : null,
                                trailing: Text(
                                  '₹${expense.amount.toStringAsFixed(2).toIndianFormat()}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: AbsorbPointer(
        absorbing: viewModel.isBusy,
        child: Container(
          height: kToolbarHeight * 1.5,
          decoration: BoxDecoration(
            color: viewModel.isBusy
                ? Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5)
                : Theme.of(context).colorScheme.inversePrimary,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Expenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${viewModel.filteredExpenses.length} items',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Text(
                '₹${viewModel.totalFilteredAmount.toStringAsFixed(2).toIndianFormat()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: !viewModel.isBusy
          ? OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                foregroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              onPressed: () {
                viewModel.showAddExpenseBottomSheet();
              },
              child: Text(
                'Add Expense',
                style: const TextStyle(color: Colors.black).button16,
              ),
            )
          : null,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
