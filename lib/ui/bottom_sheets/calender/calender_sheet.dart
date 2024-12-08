import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import '../../widgets/date_selector/date_selector_widget.dart';
import 'calender_sheet_model.dart';

class CalenderSheet extends StackedView<CalenderSheetModel> {
  final Function(SheetResponse<DateSelection> response)? completer;
  final SheetRequest request;
  const CalenderSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CalenderSheetModel viewModel,
    Widget? child,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DateSelectorWidget(
            selectedYear: viewModel.selectedYear,
            selectedMonth: viewModel.selectedMonth,
            selectedDay: viewModel.selectedDay,
            onYearSelected: viewModel.setSelectedYear,
            onMonthSelected: viewModel.setSelectedMonth,
            onDaySelected: viewModel.setSelectedDay,
            getExpenseCountForDay: viewModel.getExpenseCountForDay,
            daysInSelectedMonth: viewModel.daysInSelectedMonth,
            availableYears: viewModel.availableYears,
          ),
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: viewModel.selectionWarningMessage != null
          //         ? Colors.orange.withOpacity(0.1)
          //         : Colors.transparent,
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(
          //       color: viewModel.selectionWarningMessage != null
          //           ? Colors.orange.withOpacity(0.3)
          //           : Colors.transparent,
          //     ),
          //   ),
          //   child: Row(
          //     children: [
          //       if (viewModel.selectionWarningMessage != null)
          //         const Icon(
          //           Icons.warning_amber_rounded,
          //           color: Colors.orange,
          //           size: 20,
          //         ),
          //       const SizedBox(width: 8),
          //       Expanded(
          //         child: Text(
          //           viewModel.selectionWarningMessage ?? ' ',
          //           style: TextStyle(
          //             color: Colors.orange[800],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => completer?.call(
                  SheetResponse(confirmed: false),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed:
                    // viewModel.currentSelectionExpenseCount > 0
                    //     ?
                    () => completer?.call(
                  SheetResponse(
                    confirmed: true,
                    data: DateSelection(
                      year: viewModel.selectedYear,
                      month: viewModel.selectedMonth,
                      day: viewModel.selectedDay,
                    ),
                  ),
                ),
                // : null,
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  CalenderSheetModel viewModelBuilder(BuildContext context) {
    final data = request.data as Map<String, dynamic>;
    return CalenderSheetModel(
      initialYear: data['selectedYear'] as int,
      initialMonth: data['selectedMonth'] as int?,
      initialDay: data['selectedDay'] as int?,
    );
  }

  @override
  void onViewModelReady(CalenderSheetModel viewModel) {
    viewModel.initialise();
    super.onViewModelReady(viewModel);
  }
}

class DateSelection {
  final int year;
  final int? month;
  final int? day;

  DateSelection({
    required this.year,
    this.month,
    this.day,
  });
}
