import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/profile_view_screen.dart';
import '../screens/profile/profile_edit_screen.dart';
import '../screens/profile/profile_complete_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/rent/rent_screen.dart';
import '../screens/rent/rent_detail_screen.dart';
import '../screens/building/building_screen.dart';
import '../screens/building/building_detail_screen.dart';
import '../screens/building/building_room_detail_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/location/location_picker_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/contact/contact_screen.dart';
import '../services/auth_service.dart';
import '../services/onboarding_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = AuthService.isAuthenticated;
      final hasCompletedOnboarding = OnboardingService.hasCompletedOnboarding;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/signup';
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      // Allow splash screen to handle its own navigation
      if (isSplash) {
        return null;
      }

      // First-time user flow: redirect to onboarding if not completed
      if (!hasCompletedOnboarding && !isOnboarding && !isSplash) {
        return '/onboarding';
      }

      // If onboarding is completed but user not authenticated, go to login
      if (hasCompletedOnboarding && !isAuthenticated && !isLoggingIn && !isRegistering && !isOnboarding) {
        return '/login';
      }

      // If authenticated and trying to access login/register, redirect to home
      if (isAuthenticated && (isLoggingIn || isRegistering || isOnboarding)) {
        return '/home';
      }

      return null;
    },
    refreshListenable: GoRouterRefreshStream(AuthService.authStateChanges),
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
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
        routes: [
          GoRoute(
            path: 'view',
            name: 'profile-view',
            builder: (context, state) => const ProfileViewScreen(),
          ),
          GoRoute(
            path: 'edit',
            name: 'profile-edit',
            builder: (context, state) => const ProfileEditScreen(),
          ),
          GoRoute(
            path: 'complete',
            name: 'profile-complete',
            builder: (context, state) => const ProfileCompleteScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/rent',
        name: 'rent',
        builder: (context, state) {
          // Extract query parameters for search filters
          final searchParams = state.uri.queryParameters.isNotEmpty
              ? state.uri.queryParameters
              : null;
          return RentScreen(searchParams: searchParams);
        },
        routes: [
          GoRoute(
            path: ':rentId',
            name: 'rent-detail',
            builder: (context, state) {
              final rentId = state.pathParameters['rentId']!;
              return RentDetailScreen(rentId: rentId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/building',
        name: 'building',
        builder: (context, state) => const BuildingScreen(),
        routes: [
          GoRoute(
            path: ':buildingId',
            name: 'building-detail',
            builder: (context, state) {
              final buildingId = state.pathParameters['buildingId']!;
              return BuildingDetailScreen(buildingId: buildingId);
            },
            routes: [
              GoRoute(
                path: 'room/:roomId',
                name: 'building-room-detail',
                builder: (context, state) {
                  final buildingId = state.pathParameters['buildingId']!;
                  final roomId = state.pathParameters['roomId']!;
                  return BuildingRoomDetailScreen(
                    buildingId: buildingId,
                    roomId: roomId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/location-picker',
        name: 'location-picker',
        builder: (context, state) {
          final selectedCityId = state.uri.queryParameters['selectedCityId'];
          return LocationPickerScreen(selectedCityId: selectedCityId);
        },
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
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
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String profile = 'profile';
  static const String profileView = 'profile-view';
  static const String profileEdit = 'profile-edit';
  static const String profileComplete = 'profile-complete';
  static const String settings = 'settings';
  static const String rent = 'rent';
  static const String rentDetail = 'rent-detail';
  static const String building = 'building';
  static const String buildingDetail = 'building-detail';
  static const String buildingRoomDetail = 'building-room-detail';
  static const String favorites = 'favorites';
  static const String locationPicker = 'location-picker';
  static const String contact = 'contact';
}

// Route paths for easy reference
class RoutePaths {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileView = '/profile/view';
  static const String profileEdit = '/profile/edit';
  static const String profileComplete = '/profile/complete';
  static const String settings = '/settings';
  static const String rent = '/rent';
  static const String rentDetail = '/rent/:rentId';
  static const String building = '/building';
  static const String buildingDetail = '/building/:buildingId';
  static const String buildingRoomDetail = '/building/:buildingId/room/:roomId';
  static const String favorites = '/favorites';
  static const String locationPicker = '/location-picker';
  static const String contact = '/contact';
}