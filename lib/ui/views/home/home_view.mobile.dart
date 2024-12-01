import 'package:expense_manager/ui/views/all_expenses/all_expenses_view.dart';
import 'package:expense_manager/ui/views/current_expense/current_expense_view.dart';
import 'package:expense_manager/ui/views/my_account/my_account_view.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeViewMobile extends ViewModelWidget<HomeViewModel> {
  const HomeViewMobile({super.key});

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    return PopScope(
      canPop: viewModel.currentIndex == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (viewModel.currentIndex > 0) {
          viewModel.setIndex(0);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Scaffold(
            body: switch (viewModel.currentIndex) {
              0 => const CurrentExpenseView(),
              1 => const AllExpensesView(),
              2 => const MyAccountView(),
              _ => const CurrentExpenseView(),
            },
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: viewModel.currentIndex,
              onTap: viewModel.setIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Current',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'All',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'My Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
