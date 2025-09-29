import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';

import '/backend/supabase/supabase.dart';

import '/auth/base_auth_user_provider.dart';

import '/main.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/lat_lng.dart';
import '/flutter_flow/place.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'serialization_util.dart';

import '/index.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

// Función para verificar autenticación y navegar correctamente
Widget _checkAuthAndNavigate() {
  // Verificar si hay una sesión activa en Supabase
  final session = SupaFlow.client.auth.currentSession;
  final user = SupaFlow.client.auth.currentUser;
  
  print('Checking auth state:');
  print('  Session exists: ${session != null}');
  print('  User exists: ${user != null}');
  print('  User email: ${user?.email}');
  
  if (session != null && user != null) {
    print('User is logged in, navigating to MainPage');
    // Usuario autenticado, ir a la página principal
    return MainPageWidget();
  } else {
    print('User is not logged in, navigating to Welcome');
    // Usuario no autenticado, ir a la página de bienvenida
    return NewWelcomePageWidget();
  }
}


const kTransitionInfoKey = '__transition_info__';

GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      navigatorKey: appNavigatorKey,
      errorBuilder: (context, state) => NewWelcomePageWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => _checkAuthAndNavigate(),
        ),
        FFRoute(
          name: ManageUsersPageWidget.routeName,
          path: ManageUsersPageWidget.routePath,
          builder: (context, params) => ManageUsersPageWidget(),
        ),
        FFRoute(
          name: PushNotificationPageWidget.routeName,
          path: PushNotificationPageWidget.routePath,
          builder: (context, params) => PushNotificationPageWidget(),
        ),
        FFRoute(
          name: SupportChatAdminPageWidget.routeName,
          path: SupportChatAdminPageWidget.routePath,
          builder: (context, params) => SupportChatAdminPageWidget(),
        ),
        FFRoute(
          name: WelcomePageeWidget.routeName,
          path: WelcomePageeWidget.routePath,
          builder: (context, params) => WelcomePageeWidget(),
        ),
        FFRoute(
          name: NewWelcomePageWidget.routeName,
          path: NewWelcomePageWidget.routePath,
          builder: (context, params) => NewWelcomePageWidget(),
        ),
        // ELIMINADAS: NewWelcomePage2, 3, 4
        FFRoute(
          name: LoginPageWidget.routeName,
          path: LoginPageWidget.routePath,
          builder: (context, params) => LoginPageWidget(),
        ),
        FFRoute(
          name: SignUpPageWidget.routeName,
          path: SignUpPageWidget.routePath,
          builder: (context, params) => SignUpPageWidget(),
        ),
        FFRoute(
          name: MainPageWidget.routeName,
          path: MainPageWidget.routePath,
          builder: (context, params) => MainPageWidget(),
        ),
        FFRoute(
          name: MyWalletPageWidget.routeName,
          path: MyWalletPageWidget.routePath,
          builder: (context, params) => MyWalletPageWidget(),
        ),
        FFRoute(
          name: MyProfilePageWidget.routeName,
          path: MyProfilePageWidget.routePath,
          builder: (context, params) => MyProfilePageWidget(),
        ),
        FFRoute(
          name: ProfilePageWidget.routeName,
          path: ProfilePageWidget.routePath,
          builder: (context, params) => ProfilePageWidget(),
        ),
        FFRoute(
          name: MembershipPageWidget.routeName,
          path: MembershipPageWidget.routePath,
          builder: (context, params) => MembershipPageWidget(),
        ),
        FFRoute(
          name: WalletPageWidget.routeName,
          path: WalletPageWidget.routePath,
          builder: (context, params) => WalletPageWidget(),
        ),
        FFRoute(
          name: BookingResultsPageWidget.routeName,
          path: BookingResultsPageWidget.routePath,
          builder: (context, params) => BookingResultsPageWidget(),
        ),
        FFRoute(
          name: BookingDetailsPageWidget.routeName,
          path: BookingDetailsPageWidget.routePath,
          builder: (context, params) => BookingDetailsPageWidget(),
        ),
        FFRoute(
          name: ConfirmBookingPageWidget.routeName,
          path: ConfirmBookingPageWidget.routePath,
          builder: (context, params) => ConfirmBookingPageWidget(),
        ),
        FFRoute(
          name: PaymentPageWidget.routeName,
          path: PaymentPageWidget.routePath,
          builder: (context, params) => PaymentPageWidget(),
        ),
        FFRoute(
          name: PaymentSuccessPagWidget.routeName,
          path: PaymentSuccessPagWidget.routePath,
          builder: (context, params) => PaymentSuccessPagWidget(),
        ),
        FFRoute(
          name: MyBookingsPageWidget.routeName,
          path: MyBookingsPageWidget.routePath,
          builder: (context, params) => MyBookingsPageWidget(),
        ),
        // ELIMINADA: Página de perfil antigua con fondo claro
        FFRoute(
          name: SupportChatPageWidget.routeName,
          path: SupportChatPageWidget.routePath,
          builder: (context, params) => SupportChatPageWidget(),
        ),
        FFRoute(
          name: AdminDashboardPageWidget.routeName,
          path: AdminDashboardPageWidget.routePath,
          builder: (context, params) => AdminDashboardPageWidget(),
        ),
        FFRoute(
          name: UsersManagementPageWidget.routeName,
          path: UsersManagementPageWidget.routePath,
          builder: (context, params) => UsersManagementPageWidget(),
        ),
        FFRoute(
          name: BookingsManagementPagWidget.routeName,
          path: BookingsManagementPagWidget.routePath,
          builder: (context, params) => BookingsManagementPagWidget(),
        ),
        FFRoute(
          name: VendorsProductsManagementPageWidget.routeName,
          path: VendorsProductsManagementPageWidget.routePath,
          builder: (context, params) => VendorsProductsManagementPageWidget(),
        ),
        FFRoute(
          name: PaymentPageCardWidget.routeName,
          path: PaymentPageCardWidget.routePath,
          builder: (context, params) => PaymentPageCardWidget(),
        ),
        FFRoute(
          name: MembershipsManagementPageWidget.routeName,
          path: MembershipsManagementPageWidget.routePath,
          builder: (context, params) => MembershipsManagementPageWidget(),
        ),
        FFRoute(
          name: WalletTransactionsPageWidget.routeName,
          path: WalletTransactionsPageWidget.routePath,
          builder: (context, params) => WalletTransactionsPageWidget(),
        ),
        FFRoute(
          name: AdminSettingsPageWidget.routeName,
          path: AdminSettingsPageWidget.routePath,
          builder: (context, params) => AdminSettingsPageWidget(),
        ),
        FFRoute(
          name: ReferralPointsPageWidget.routeName,
          path: ReferralPointsPageWidget.routePath,
          builder: (context, params) => ReferralPointsPageWidget(),
        ),
        FFRoute(
          name: AffiliateSystemPageWidget.routeName,
          path: AffiliateSystemPageWidget.routePath,
          builder: (context, params) => AffiliateSystemPageWidget(),
        ),
        FFRoute(
          name: MembershipSelectionPageWidget.routeName,
          path: MembershipSelectionPageWidget.routePath,
          builder: (context, params) => MembershipSelectionPageWidget(),
        ),
        FFRoute(
          name: BookingSearchPageWidget.routeName,
          path: BookingSearchPageWidget.routePath,
          builder: (context, params) => BookingSearchPageWidget(),
        ),
        FFRoute(
          name: SearchResultsPageWidget.routeName,
          path: SearchResultsPageWidget.routePath,
          builder: (context, params) => SearchResultsPageWidget(),
        ),
        FFRoute(
          name: BookingDetailsPagWidget.routeName,
          path: BookingDetailsPagWidget.routePath,
          builder: (context, params) => BookingDetailsPagWidget(),
        ),
        FFRoute(
          name: CheckoutPageWidget.routeName,
          path: CheckoutPageWidget.routePath,
          builder: (context, params) => CheckoutPageWidget(),
        ),
        FFRoute(
          name: DestinationsPageWidget.routeName,
          path: DestinationsPageWidget.routePath,
          builder: (context, params) => DestinationsPageWidget(),
        ),
        FFRoute(
          name: PaymentFailedWidget.routeName,
          path: PaymentFailedWidget.routePath,
          builder: (context, params) => PaymentFailedWidget(),
        ),
        FFRoute(
          name: ZellePaymentUploadPageWidget.routeName,
          path: ZellePaymentUploadPageWidget.routePath,
          builder: (context, params) => ZellePaymentUploadPageWidget(),
        ),
        FFRoute(
          name: HelpCenterPageWidget.routeName,
          path: HelpCenterPageWidget.routePath,
          builder: (context, params) => HelpCenterPageWidget(),
        ),
        FFRoute(
          name: TermsAndConditionsPageWidget.routeName,
          path: TermsAndConditionsPageWidget.routePath,
          builder: (context, params) => TermsAndConditionsPageWidget(),
        ),
        FFRoute(
          name: ContactUsPageWidget.routeName,
          path: ContactUsPageWidget.routePath,
          builder: (context, params) => ContactUsPageWidget(),
        ),
        FFRoute(
          name: FAQsPageWidget.routeName,
          path: FAQsPageWidget.routePath,
          builder: (context, params) => FAQsPageWidget(),
        ),
        FFRoute(
          name: LanguageSelectionPageWidget.routeName,
          path: LanguageSelectionPageWidget.routePath,
          builder: (context, params) => LanguageSelectionPageWidget(),
        ),
        FFRoute(
          name: AboutUsPageWidget.routeName,
          path: AboutUsPageWidget.routePath,
          builder: (context, params) => AboutUsPageWidget(),
        ),
        FFRoute(
          name: MaintenancePageWidget.routeName,
          path: MaintenancePageWidget.routePath,
          builder: (context, params) => MaintenancePageWidget(),
        ),
        FFRoute(
          name: ForceUpdatePageWidget.routeName,
          path: ForceUpdatePageWidget.routePath,
          builder: (context, params) => ForceUpdatePageWidget(),
        ),
        FFRoute(
          name: PhoneVerificationPageWidget.routeName,
          path: PhoneVerificationPageWidget.routePath,
          builder: (context, params) => PhoneVerificationPageWidget(),
        ),
        FFRoute(
          name: BookingsflihsWidget.routeName,
          path: BookingsflihsWidget.routePath,
          builder: (context, params) => BookingsflihsWidget(),
        ),
        FFRoute(
          name: FlightBookingPageWidget.routeName,
          path: FlightBookingPageWidget.routePath,
          builder: (context, params) => FlightBookingPageWidget(),
        ),
    FFRoute(
      name: HotelBookingPageWidget.routeName,
      path: HotelBookingPageWidget.routePath,
      builder: (context, params) => HotelBookingPageWidget(),
    ),
    // ELIMINADAS: TermsConditions, Settings, Notifications, PaymentMethod
    FFRoute(
      name: EmailConfirmationPageWidget.routeName,
      path: EmailConfirmationPageWidget.routePath,
      builder: (context, params) => EmailConfirmationPageWidget(
        email: params.getParam<String>('email', ParamType.String) ?? '',
      ),
    ),
    FFRoute(
      name: ForgotPasswordPageWidget.routeName,
      path: ForgotPasswordPageWidget.routePath,
      builder: (context, params) => ForgotPasswordPageWidget(),
    ),
    FFRoute(
      name: ResetPasswordPageWidget.routeName,
      path: ResetPasswordPageWidget.routePath,
      builder: (context, params) => ResetPasswordPageWidget(),
    ),
    FFRoute(
      name: VerificationCodePageWidget.routeName,
      path: VerificationCodePageWidget.routePath,
      builder: (context, params) => VerificationCodePageWidget(
        email: params.getParam<String>('email', ParamType.String) ?? '',
      ),
    ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) =>
      !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && !appStateNotifier.loggedIn) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            return '/newWelcomePage';
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = appStateNotifier.loading
              ? Center(
                  child: SizedBox(
                    width: 50.0,
                    height: 50.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        FlutterFlowTheme.of(context).primary,
                      ),
                    ),
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
