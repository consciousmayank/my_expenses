import 'package:expense_manager/app/app.locator.dart';
import 'package:expense_manager/models/logged_in_user.dart';
import 'package:expense_manager/services/storage_service.dart';
import 'package:stacked/stacked.dart';

class MyAccountSheetModel extends BaseViewModel {
  LoggedInUser? loggedInUser;
  final StorageService _storageService = locator<StorageService>();
  Future<void> fetchLoggedInUser() async {
    loggedInUser = await _storageService.getLoggedInUser();
    notifyListeners();
  }
}
