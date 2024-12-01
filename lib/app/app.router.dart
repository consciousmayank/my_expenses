// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i10;
import 'package:stacked/stacked.dart' as _i9;
import 'package:stacked_services/stacked_services.dart' as _i8;

import '../ui/views/all_expenses/all_expenses_view.dart' as _i5;
import '../ui/views/current_expense/current_expense_view.dart' as _i4;
import '../ui/views/home/home_view.dart' as _i2;
import '../ui/views/login/login_view.dart' as _i3;
import '../ui/views/my_account/my_account_view.dart' as _i6;
import '../ui/views/startup/startup_view.dart' as _i1;
import '../ui/views/unknown/unknown_view.dart' as _i7;

final stackedRouter =
    StackedRouterWeb(navigatorKey: _i8.StackedService.navigatorKey);

class StackedRouterWeb extends _i9.RootStackRouter {
  StackedRouterWeb({_i10.GlobalKey<_i10.NavigatorState>? navigatorKey})
      : super(navigatorKey);

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    StartupViewRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.StartupView(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    HomeViewRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i2.HomeView(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    LoginViewRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i3.LoginView(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    CurrentExpenseViewRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i4.CurrentExpenseView(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    AllExpensesViewRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i5.AllExpensesView(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    MyAccountViewRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i6.MyAccountView(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    UnknownViewRoute.name: (routeData) {
      return _i9.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i7.UnknownView(),
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i9.RouteConfig> get routes => [
        _i9.RouteConfig(
          StartupViewRoute.name,
          path: '/',
        ),
        _i9.RouteConfig(
          HomeViewRoute.name,
          path: '/home-view',
        ),
        _i9.RouteConfig(
          LoginViewRoute.name,
          path: '/login-view',
        ),
        _i9.RouteConfig(
          CurrentExpenseViewRoute.name,
          path: '/current-expense-view',
        ),
        _i9.RouteConfig(
          AllExpensesViewRoute.name,
          path: '/all-expenses-view',
        ),
        _i9.RouteConfig(
          MyAccountViewRoute.name,
          path: '/my-account-view',
        ),
        _i9.RouteConfig(
          UnknownViewRoute.name,
          path: '/404',
        ),
        _i9.RouteConfig(
          '*#redirect',
          path: '*',
          redirectTo: '/404',
          fullMatch: true,
        ),
      ];
}

/// generated route for
/// [_i1.StartupView]
class StartupViewRoute extends _i9.PageRouteInfo<void> {
  const StartupViewRoute()
      : super(
          StartupViewRoute.name,
          path: '/',
        );

  static const String name = 'StartupView';
}

/// generated route for
/// [_i2.HomeView]
class HomeViewRoute extends _i9.PageRouteInfo<void> {
  const HomeViewRoute()
      : super(
          HomeViewRoute.name,
          path: '/home-view',
        );

  static const String name = 'HomeView';
}

/// generated route for
/// [_i3.LoginView]
class LoginViewRoute extends _i9.PageRouteInfo<void> {
  const LoginViewRoute()
      : super(
          LoginViewRoute.name,
          path: '/login-view',
        );

  static const String name = 'LoginView';
}

/// generated route for
/// [_i4.CurrentExpenseView]
class CurrentExpenseViewRoute extends _i9.PageRouteInfo<void> {
  const CurrentExpenseViewRoute()
      : super(
          CurrentExpenseViewRoute.name,
          path: '/current-expense-view',
        );

  static const String name = 'CurrentExpenseView';
}

/// generated route for
/// [_i5.AllExpensesView]
class AllExpensesViewRoute extends _i9.PageRouteInfo<void> {
  const AllExpensesViewRoute()
      : super(
          AllExpensesViewRoute.name,
          path: '/all-expenses-view',
        );

  static const String name = 'AllExpensesView';
}

/// generated route for
/// [_i6.MyAccountView]
class MyAccountViewRoute extends _i9.PageRouteInfo<void> {
  const MyAccountViewRoute()
      : super(
          MyAccountViewRoute.name,
          path: '/my-account-view',
        );

  static const String name = 'MyAccountView';
}

/// generated route for
/// [_i7.UnknownView]
class UnknownViewRoute extends _i9.PageRouteInfo<void> {
  const UnknownViewRoute()
      : super(
          UnknownViewRoute.name,
          path: '/404',
        );

  static const String name = 'UnknownView';
}

extension RouterStateExtension on _i8.RouterService {
  Future<dynamic> navigateToStartupView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return navigateTo(
      const StartupViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToHomeView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return navigateTo(
      const HomeViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToLoginView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return navigateTo(
      const LoginViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToCurrentExpenseView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return navigateTo(
      const CurrentExpenseViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToAllExpensesView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return navigateTo(
      const AllExpensesViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToMyAccountView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return navigateTo(
      const MyAccountViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> navigateToUnknownView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return navigateTo(
      const UnknownViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithStartupView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return replaceWith(
      const StartupViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithHomeView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return replaceWith(
      const HomeViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithLoginView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return replaceWith(
      const LoginViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithCurrentExpenseView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return replaceWith(
      const CurrentExpenseViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithAllExpensesView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return replaceWith(
      const AllExpensesViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithMyAccountView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return replaceWith(
      const MyAccountViewRoute(),
      onFailure: onFailure,
    );
  }

  Future<dynamic> replaceWithUnknownView(
      {void Function(_i9.NavigationFailure)? onFailure}) async {
    return replaceWith(
      const UnknownViewRoute(),
      onFailure: onFailure,
    );
  }
}
