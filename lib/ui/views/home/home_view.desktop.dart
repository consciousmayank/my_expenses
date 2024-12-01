import 'package:expense_manager/ui/common/app_colors.dart';
import 'package:expense_manager/ui/common/app_constants.dart';
import 'package:expense_manager/ui/common/ui_helpers.dart';
import 'package:expense_manager/ui/views/home/home_view.mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeViewDesktop extends ViewModelWidget<HomeViewModel> {
  const HomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: kdDesktopMaxContentWidth,
          height: kdDesktopMaxContentHeight,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox.shrink(),
              ),
              Expanded(
                flex: 1,
                child: HomeViewMobile(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
