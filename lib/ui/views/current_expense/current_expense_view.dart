import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'current_expense_view.desktop.dart';
import 'current_expense_view.tablet.dart';
import 'current_expense_view.mobile.dart';
import 'current_expense_viewmodel.dart';

class CurrentExpenseView extends StackedView<CurrentExpenseViewModel> {
  const CurrentExpenseView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CurrentExpenseViewModel viewModel,
    Widget? child,
  ) {
    return ScreenTypeLayout.builder(
      mobile: (_) => const CurrentExpenseViewMobile(),
      tablet: (_) => const CurrentExpenseViewTablet(),
      desktop: (_) => const CurrentExpenseViewDesktop(),
    );
  }

  @override
  CurrentExpenseViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CurrentExpenseViewModel();

  @override
  void onViewModelReady(CurrentExpenseViewModel viewModel) =>
      viewModel.initialize();
}
