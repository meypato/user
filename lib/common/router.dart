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
import '../screens/rent/rent_detail_screen.dart';
import '../screens/building/building_screen.dart';
import '../screens/building/building_detail_screen.dart';
import '../screens/building/building_room_detail_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/location/location_picker_screen.dart';
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
  static const String rentDetail = 'rent-detail';
  static const String building = 'building';
  static const String buildingDetail = 'building-detail';
  static const String buildingRoomDetail = 'building-room-detail';
  static const String favorites = 'favorites';
  static const String locationPicker = 'location-picker';
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
  static const String rentDetail = '/rent/:rentId';
  static const String building = '/building';
  static const String buildingDetail = '/building/:buildingId';
  static const String buildingRoomDetail = '/building/:buildingId/room/:roomId';
  static const String favorites = '/favorites';
  static const String locationPicker = '/location-picker';
}