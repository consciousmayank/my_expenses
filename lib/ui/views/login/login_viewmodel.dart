import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/app/app.router.dart';
import 'package:expense_manager/services/app_authentication_service.dart';
import 'package:expense_manager/services/drive_backup_service.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:expense_manager/setup/setup_snackbar_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends BaseViewModel {
  final _routerService = locator<RouterService>();
  final _authService = locator<AppAuthenticationService>();
  final _storageService = locator<StorageService>();
  final _snackbarService = locator<SnackbarService>();

  String? _errorMessage;

  int _selectedOnboardingPage = 0;
  String? get errorMessage => _errorMessage;

  int get selectedOnboardingPage => _selectedOnboardingPage;

  Future<void> signInWithGoogle() async {
    try {
      setBusy(true);
      _errorMessage = null;

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        // Successfully signed in
        await _storageService.saveLoggedInUser(
          user: _authService.currentUser!,
          accessToken: userCredential.credential!.accessToken,
        );
        locator<DriveBackupService>().initializeEncryption(_authService.currentUser!.email ?? '');
        await _routerService.replaceWithHomeView();
      } else {
        _errorMessage = 'Sign in failed. Please try again.';
      }
    } catch (e) {
      _errorMessage = e.toString();
      _snackbarService.showCustomSnackBar(
        variant: SnackbarType.error,
        message: _errorMessage!,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> continueAsGuest() async {
    try {
      setBusy(true);
      await _routerService.replaceWithHomeView();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  setSelectedOnboardingPage(int index) {
    _selectedOnboardingPage = index;
    notifyListeners();
  }
}
