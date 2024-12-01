import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'all_expenses_viewmodel.dart';

class AllExpensesViewDesktop extends ViewModelWidget<AllExpensesViewModel> {
  const AllExpensesViewDesktop({super.key});

  @override
  Widget build(BuildContext context, AllExpensesViewModel viewModel) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Hello, DESKTOP UI!',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
