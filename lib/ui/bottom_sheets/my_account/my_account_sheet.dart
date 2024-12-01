import 'package:expense_manager/extensions/textstyles_extension.dart';
import 'package:expense_manager/ui/widgets/common/url_image_view/url_image_view.dart';
import 'package:flutter/material.dart';
import 'package:expense_manager/ui/common/app_colors.dart';
import 'package:expense_manager/ui/common/ui_helpers.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'my_account_sheet_model.dart';

class MyAccountSheet extends StackedView<MyAccountSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const MyAccountSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MyAccountSheetModel viewModel,
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
      child: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            UrlImageView(
                                imageUrl: viewModel.loggedInUser?.photoUrl),
                            const SizedBox(height: 16),
                            Text(
                              viewModel.loggedInUser?.displayName ??
                                  'Guest User',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              viewModel.loggedInUser?.email ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(
                        endIndent: 4,
                        indent: 4,
                        height: 0,
                        thickness: 1,
                      ),
                      ListTile(
                        onTap: () {
                          completer?.call(
                            SheetResponse(
                              confirmed: true,
                              data: MyAccountSheetActions.backUpData,
                            ),
                          );
                        },
                        splashColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        hoverColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        leading: Icon(
                          Icons.cloud_upload_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          'Backup to Google Drive',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const Divider(
                        endIndent: 16,
                        indent: 16,
                        height: 0,
                        thickness: 1,
                      ),
                      ListTile(
                        onTap: () {
                          completer?.call(
                            SheetResponse(
                              confirmed: true,
                              data: MyAccountSheetActions.restoreData,
                            ),
                          );
                        },
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        splashColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        hoverColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        leading: Icon(
                          Icons.cloud_download_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          'Restore from Google Drive',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const Divider(
                        endIndent: 16,
                        indent: 16,
                        height: 0,
                        thickness: 1,
                      ),
                      ListTile(
                        onTap: () {
                          completer?.call(
                            SheetResponse(
                              confirmed: true,
                              data: MyAccountSheetActions.addRecurringExpense,
                            ),
                          );
                        },
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        splashColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        hoverColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        leading: Icon(
                          Icons.add,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          'Add Recurring Expense',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const Divider(
                        endIndent: 16,
                        indent: 16,
                        height: 0,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
                verticalSpaceTiny,
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize:
                        Size(screenWidth(context) - 100, kToolbarHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    completer?.call(
                      SheetResponse(
                        confirmed: true,
                        data: MyAccountSheetActions.logout,
                      ),
                    );
                  },
                  child: Text(
                    'Logout',
                    style: const TextStyle().heading16,
                  ),
                ),
                verticalSpaceMedium,
              ],
            ),
    );
  }

  @override
  MyAccountSheetModel viewModelBuilder(BuildContext context) =>
      MyAccountSheetModel();

  @override
  void onViewModelReady(MyAccountSheetModel viewModel) {
    viewModel.fetchLoggedInUser();
    super.onViewModelReady(viewModel);
  }
}

enum MyAccountSheetActions {
  backUpData,
  restoreData,
  addRecurringExpense,
  logout,
}
