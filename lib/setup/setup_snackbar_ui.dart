import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

import '../app/app.locator.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
  persistent,
}

void setupSnackbarUi() {
  final service = locator<SnackbarService>();

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.success,
    config: SnackbarConfig(
      backgroundColor: Colors.green,
      textColor: Colors.white,
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(16),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.error,
    config: SnackbarConfig(
      backgroundColor: Colors.red,
      textColor: Colors.white,
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(16),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.warning,
    config: SnackbarConfig(
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(16),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.info,
    config: SnackbarConfig(
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(16),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.persistent,
    config: SnackbarConfig(
      backgroundColor: Colors.grey[800]!,
      textColor: Colors.white,
      borderRadius: 8,
      // dismissDirection: DismissDirection.down,
      isDismissible: true,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(16),
      snackStyle: SnackStyle.FLOATING,
      snackPosition: SnackPosition.BOTTOM,
      mainButtonTextColor: Colors.white,
      messageColor: Colors.white,
      mainButtonStyle: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        foregroundColor: Colors.white,
      ),
    ),
  );
}

extension SnackbarServiceExtension on SnackbarService {
  void showPersistentSnackbar({
    required String message,
    required Function() onOkPressed,
    // required Function() onCancelPressed,
  }) {
    showCustomSnackBar(
      message: message,
      variant: SnackbarType.persistent,
      duration: const Duration(days: 1),
      mainButtonTitle: 'OK',
      onMainButtonTapped: () {
        onOkPressed();
        closeSnackbar();
      },
    );
  }
} 