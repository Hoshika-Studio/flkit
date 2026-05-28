import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
{{#use_riverpod}}
import 'package:riverpod_annotation/riverpod_annotation.dart';
{{/use_riverpod}}
import 'package:{{package_name}}/core/widgets/scaffold_with_nav_bar.dart';
import 'package:{{package_name}}/features/auth/application/auth_controller.dart';
import 'package:{{package_name}}/features/auth/presentation/login_screen.dart';
import 'package:{{package_name}}/features/auth/presentation/register_screen.dart';
import 'package:{{package_name}}/features/favorite/presentation/favorite_screen.dart';
import 'package:{{package_name}}/features/home/presentation/home_screen.dart';
import 'package:{{package_name}}/features/onboarding/presentation/onboarding_screen.dart';
import 'package:{{package_name}}/features/search/presentation/search_screen.dart';
import 'package:{{package_name}}/features/settings/presentation/settings_screen.dart';

{{#use_riverpod}}
part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authStateNotifier = ValueNotifier(ref.read(authControllerProvider));

  ref.listen(authControllerProvider, (_, next) {
    authStateNotifier.value = next;
  });

  return _createRouter(
    refreshListenable: authStateNotifier,
    isAuthenticated: () => authStateNotifier.value.value != null,
    isLoading: () => authStateNotifier.value.isLoading,
  );
}
{{/use_riverpod}}
{{^use_riverpod}}
GoRouter createAppRouter() {
  return _createRouter(
    refreshListenable: authController,
    isAuthenticated: () => authController.user != null,
    isLoading: () => authController.isLoading,
  );
}
{{/use_riverpod}}

GoRouter _createRouter({
  required Listenable refreshListenable,
  required bool Function() isAuthenticated,
  required bool Function() isLoading,
}) {
  return GoRouter(
    initialLocation: OnboardingScreen.route,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      if (isLoading()) return null;

      final isAuthRoute = {
        OnboardingScreen.route,
        LoginScreen.route,
        RegisterScreen.route,
      }.contains(state.matchedLocation);

      if (!isAuthenticated() && !isAuthRoute) {
        return OnboardingScreen.route;
      }

      if (isAuthenticated() && isAuthRoute) {
        return HomeScreen.route;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: OnboardingScreen.route,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: LoginScreen.route,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.route,
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeScreen.route,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SearchScreen.route,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: FavoriteScreen.route,
                builder: (context, state) => const FavoriteScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SettingsScreen.route,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
