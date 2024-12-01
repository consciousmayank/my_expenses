import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'my_account_viewmodel.dart';

class MyAccountViewDesktop extends ViewModelWidget<MyAccountViewModel> {
  const MyAccountViewDesktop({super.key});

  @override
  Widget build(BuildContext context, MyAccountViewModel viewModel) {
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
