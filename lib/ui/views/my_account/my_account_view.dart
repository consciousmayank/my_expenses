import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'my_account_view.desktop.dart';
import 'my_account_view.tablet.dart';
import 'my_account_view.mobile.dart';
import 'my_account_viewmodel.dart';

class MyAccountView extends StackedView<MyAccountViewModel> {
  const MyAccountView({super.key});

  @override
  Widget builder(
    BuildContext context,
    MyAccountViewModel viewModel,
    Widget? child,
  ) {
    return ScreenTypeLayout.builder(
      mobile: (_) => const MyAccountViewMobile(),
      tablet: (_) => const MyAccountViewTablet(),
      desktop: (_) => const MyAccountViewDesktop(),
    );
  }

  @override
  MyAccountViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MyAccountViewModel();

  @override
  void onViewModelReady(MyAccountViewModel viewModel) {
    viewModel.fetchLoggedInUser();
    super.onViewModelReady(viewModel);
  }
}
