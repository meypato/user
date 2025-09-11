import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'configs/supabase_config.dart';
import 'common/router.dart';
import 'themes/theme_provider.dart';
import 'providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
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
        profileProvider.loadProfile();
      }

      // Listen to auth state changes and load profile when user signs in
      supabase.auth.onAuthStateChange.listen((data) {
        if (!mounted) return;
        
        final profileProvider = context.read<ProfileProvider>();
        final session = data.session;
        
        if (session != null) {
          // User signed in, load profile
          profileProvider.loadProfile();
        } else {
          // User signed out, clear profile
          profileProvider.clearProfile();
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

