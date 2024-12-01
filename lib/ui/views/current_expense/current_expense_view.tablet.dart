import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'current_expense_viewmodel.dart';

class CurrentExpenseViewTablet
    extends ViewModelWidget<CurrentExpenseViewModel> {
  const CurrentExpenseViewTablet({super.key});

  @override
  Widget build(BuildContext context, CurrentExpenseViewModel viewModel) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Hello, TABLET UI!',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
