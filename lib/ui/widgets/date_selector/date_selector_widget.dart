import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DateSelectorWidget extends StatelessWidget {
  final int selectedYear;
  final int? selectedMonth;
  final int? selectedDay;
  final Function(int) onYearSelected;
  final Function(int?) onMonthSelected;
  final Function(int?) onDaySelected;
  final int Function(int) getExpenseCountForDay;
  final int daysInSelectedMonth;
  final List<int> availableYears;

  const DateSelectorWidget({
    super.key,
    required this.selectedYear,
    required this.selectedMonth,
    required this.selectedDay,
    required this.onYearSelected,
    required this.onMonthSelected,
    required this.onDaySelected,
    required this.getExpenseCountForDay,
    required this.daysInSelectedMonth,
    required this.availableYears,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Year selector
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableYears.length,
            itemBuilder: (context, index) {
              final year = availableYears[index];
              final isSelected = year == selectedYear;
              return ActionChip(
                side: BorderSide(
                    color: Theme.of(context).primaryColor, width: 0.5),
                elevation: isSelected ? 4 : 0,
                shadowColor: Colors.black87,
                label: Text(
                  year.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? Colors.white : null,
                      ),
                ),
                onPressed: () => onYearSelected(year),
                backgroundColor: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              )
                  .animate(
                    target: isSelected ? 1 : 0,
                  )
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                  );
            },
          ),
        ),

        // Month selector with clear button
        // if (selectedMonth != null)
        //   Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16),
        //     child: Row(
        //       children: [
        //         TextButton.icon(
        //           onPressed: () => onMonthSelected(null),
        //           icon: const Icon(Icons.clear),
        //           label: const Text('Show All Months'),
        //         ),
        //       ],
        //     ),
        //   ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(12, (index) {
              final month = index + 1;
              final isSelected = month == selectedMonth;
              return ActionChip(
                shadowColor: Colors.black87,
                side: BorderSide(
                    color: Theme.of(context).primaryColor, width: 0.5),
                elevation: isSelected ? 4 : 0,
                label: Text(
                  _getMonthName(month),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? Colors.white : null,
                      ),
                ),
                onPressed: () => onMonthSelected(month),
                backgroundColor: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              )
                  .animate(
                    target: isSelected ? 1 : 0,
                  )
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                  );
            }),
          ),
        ),

        // Show day selector only if month is selected
        if (selectedMonth != null) ...[
          // if (selectedDay != null)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16),
          //     child: Row(
          //       children: [
          //         TextButton.icon(
          //           onPressed: () => onDaySelected(null),
          //           icon: const Icon(Icons.clear),
          //           label: const Text('Show Whole Month'),
          //         ),
          //       ],
          //     ),
          //   ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: daysInSelectedMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == selectedDay;
              final expenseCount = getExpenseCountForDay(day);

              return GestureDetector(
                onTap: () => onDaySelected(day),
                child: Material(
                  elevation: isSelected ? 4 : 0,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                day.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: isSelected ? Colors.white : null,
                                      fontSize: 16,
                                    ),
                              ),
                            ),
                            if (expenseCount > 0) ...[
                              const SizedBox(height: 2),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 2),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.2)
                                        : Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    expenseCount.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(
                    target: isSelected ? 1 : 0,
                  )
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                  );
            },
          ),
        ],
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
