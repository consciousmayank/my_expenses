import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'current_expense_viewmodel.dart';

class CurrentExpenseViewDesktop
    extends ViewModelWidget<CurrentExpenseViewModel> {
  const CurrentExpenseViewDesktop({super.key});

  @override
  Widget build(BuildContext context, CurrentExpenseViewModel viewModel) {
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
