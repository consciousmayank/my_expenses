import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'all_expenses_view.desktop.dart';
import 'all_expenses_view.tablet.dart';
import 'all_expenses_view.mobile.dart';
import 'all_expenses_viewmodel.dart';

class AllExpensesView extends StackedView<AllExpensesViewModel> {
  const AllExpensesView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AllExpensesViewModel viewModel,
    Widget? child,
  ) {
    return ScreenTypeLayout.builder(
      mobile: (_) => const AllExpensesViewMobile(),
      tablet: (_) => const AllExpensesViewTablet(),
      desktop: (_) => const AllExpensesViewDesktop(),
    );
  }

  @override
  AllExpensesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      AllExpensesViewModel();

  @override
  void onViewModelReady(AllExpensesViewModel viewModel) {
    viewModel.initialise();
    super.onViewModelReady(viewModel);
  }
}
