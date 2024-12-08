import 'package:expense_manager/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:expense_manager/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:expense_manager/ui/views/home/home_view.dart';
import 'package:expense_manager/ui/views/startup/startup_view.dart';
import 'package:expense_manager/ui/views/unknown/unknown_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:expense_manager/services/app_authentication_service.dart';
import 'package:expense_manager/services/drive_backup_service.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:expense_manager/ui/views/login/login_view.dart';
import 'package:expense_manager/ui/views/current_expense/current_expense_view.dart';
import 'package:expense_manager/ui/views/all_expenses/all_expenses_view.dart';
import 'package:expense_manager/ui/views/my_account/my_account_view.dart';
import 'package:expense_manager/ui/bottom_sheets/view/view_sheet.dart';
import 'package:expense_manager/ui/bottom_sheets/edit_delete/edit_delete_sheet.dart';
import 'package:expense_manager/ui/bottom_sheets/add_edit_expense/add_edit_expense_sheet.dart';
import 'package:expense_manager/ui/bottom_sheets/calender/calender_sheet.dart';
import 'package:expense_manager/ui/bottom_sheets/my_account/my_account_sheet.dart';
import 'package:expense_manager/ui/bottom_sheets/recurring_expense/recurring_expense_sheet.dart';
// @stacked-import

@StackedApp(
  routes: [
    CustomRoute(page: StartupView, initial: true),
    CustomRoute(page: HomeView),
    CustomRoute(page: LoginView),
    CustomRoute(page: CurrentExpenseView),
    CustomRoute(page: AllExpensesView),
    CustomRoute(page: MyAccountView),
// @stacked-route

    CustomRoute(page: UnknownView, path: '/404'),

    /// When none of the above routes match, redirect to UnknownView
    RedirectRoute(path: '*', redirectTo: '/404'),
  ],
  dependencies: [
    InitializableSingleton(classType: StorageService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: RouterService),
    LazySingleton(classType: AppAuthenticationService),
    LazySingleton(classType: DriveBackupService),
    // LazySingleton(classType: StorageService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    StackedBottomsheet(classType: ViewSheet),
    StackedBottomsheet(classType: EditDeleteSheet),
    StackedBottomsheet(classType: AddEditExpenseSheet),
    StackedBottomsheet(classType: CalenderSheet),
    StackedBottomsheet(classType: MyAccountSheet),
    StackedBottomsheet(classType: RecurringExpenseSheet),
// @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
