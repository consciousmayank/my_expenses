import 'package:flutter_test/flutter_test.dart';
import 'package:expense_manager/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('AppAuthenticationServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
