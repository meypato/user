import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/rent/rent_screen.dart';
import '../services/auth_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = AuthService.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/signup';

      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/home';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(AuthService.authStateChanges),
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile-details',
        name: 'profile-details',
        builder: (context, state) => const ProfileDetailScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/rent',
        name: 'rent',
        builder: (context, state) => const RentScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Route names for easy reference
class RouteNames {
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String profileDetails = 'profile-details';
  static const String settings = 'settings';
  static const String rent = 'rent';
}

// Route paths for easy reference
class RoutePaths {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileDetails = '/profile-details';
  static const String settings = '/settings';
  static const String rent = '/rent';
}