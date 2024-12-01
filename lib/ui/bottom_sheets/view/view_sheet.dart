import 'package:flutter/material.dart';
import 'package:expense_manager/ui/common/app_colors.dart';
import 'package:expense_manager/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'view_sheet_model.dart';

class ViewSheet extends StackedView<ViewSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const ViewSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ViewSheetModel viewModel,
    Widget? child,
  ) {
    ViewSheetArgs args = request.data;

    return args.child;
  }

  @override
  ViewSheetModel viewModelBuilder(BuildContext context) => ViewSheetModel();
}

class ViewSheetArgs {
  final Widget child;
  const ViewSheetArgs({required this.child});
}
