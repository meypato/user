import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'configs/supabase_config.dart';
import 'common/router.dart';
import 'themes/theme_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/onboarding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize OnboardingService
  await OnboardingService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load profile data when app starts if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supabase = Supabase.instance.client;
      if (supabase.auth.currentUser != null) {
        final profileProvider = context.read<ProfileProvider>();
        final favoritesProvider = context.read<FavoritesProvider>();
        profileProvider.loadProfile();
        favoritesProvider.loadFavorites();
      }

      // Listen to auth state changes and load profile when user signs in
      supabase.auth.onAuthStateChange.listen((data) {
        if (!mounted) return;

        final profileProvider = context.read<ProfileProvider>();
        final favoritesProvider = context.read<FavoritesProvider>();
        final session = data.session;

        if (session != null) {
          // User signed in, load profile and favorites
          profileProvider.loadProfile();
          favoritesProvider.loadFavorites();
        } else {
          // User signed out, clear profile and favorites
          profileProvider.clearProfile();
          favoritesProvider.clearFavorites();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Meypato',
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

