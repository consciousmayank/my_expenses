import 'package:expense_manager/services/storage_service.dart';
import 'package:expense_manager/setup/setup_snackbar_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

class StartupViewModel extends BaseViewModel {
  final _routerService = locator<RouterService>();
  final _storageService = locator<StorageService>();
  final _snackbarService = locator<SnackbarService>();

  // Place anything here that needs to happen before we get into the application
  Future runStartupLogic() async {
    // This is where you can make decisions on where your app should navigate when
    // you have custom startup logic
    final loggedInUser = await _storageService.getLoggedInUser();
    if (loggedInUser != null) {
      await _routerService.replaceWithHomeView();
    } else {
      await _routerService.replaceWith(const LoginViewRoute());
    }
  }

  @override
  void onFutureError(error, Object? key) {
    super.onFutureError(error, key);
    _snackbarService.showCustomSnackBar(
      variant: SnackbarType.error,
      message: error.toString(),
      duration: const Duration(seconds: 3),
    );
  }
}
