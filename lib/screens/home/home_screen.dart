import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/sliding_sidebar.dart';
import '../../widgets/bottom_navigation.dart';
import '../../common/router.dart';
import '../../themes/app_colour.dart';
import '../../providers/profile_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBottomIndex = 0;

  void handleNavigation(String section) {
    switch (section) {
      case 'home':
        setState(() {
          _currentBottomIndex = 0; // Search tab
        });
        break;
      case 'properties':
        setState(() {
          _currentBottomIndex = 1; // Properties tab
        });
        break;
      case 'favorites':
        setState(() {
          _currentBottomIndex = 2; // Favorites tab
        });
        break;
      case 'nearby':
        setState(() {
          _currentBottomIndex = 3; // Near Me tab
        });
        break;
      case 'profile':
        setState(() {
          _currentBottomIndex = 4; // Profile tab
        });
        break;
      case 'settings':
        context.push(RoutePaths.settings);
        break;
      default:
        // TODO: Implement other sidebar navigation routes when screens are created
        break;
    }
  }

  void handleBottomNavigation(int index) {
    setState(() {
      _currentBottomIndex = index;
    });
    // TODO: Implement other bottom navigation routes when screens are created
  }

  @override
  Widget build(BuildContext context) {
    return SlidingSidebar(
      onNavigate: handleNavigation,
      currentBottomIndex: _currentBottomIndex,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 0),
            child: _buildCurrentScreen(),
          ),
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: _currentBottomIndex,
          onTap: handleBottomNavigation,
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentBottomIndex) {
      case 0:
        return _buildSearchScreen();
      case 1:
        return _buildSimplePlaceholder('Properties', Icons.apartment_outlined);
      case 2:
        return _buildSimplePlaceholder('Favorites', Icons.favorite_outline);
      case 3:
        return _buildSimplePlaceholder('Near Me', Icons.location_on_outlined);
      case 4:
        return _buildProfileContent();
      default:
        return _buildSearchScreen();
    }
  }

  Widget _buildSearchScreen() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Simple Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find Your Home',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Simple Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: theme.iconTheme.color?.withValues(alpha: 0.5),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search properties...',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Main Content Area - Ready for features
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.home_outlined,
                    size: 50,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Welcome to Meypato',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ready to add amazing features!',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimplePlaceholder(String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              icon,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Coming soon!',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    // Create a custom version of ProfileScreen that doesn't have its own Scaffold
    // since it will be displayed within the home screen
    return const _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends StatefulWidget {
  const _ProfileScreenContent();

  @override
  State<_ProfileScreenContent> createState() => _ProfileScreenContentState();
}

class _ProfileScreenContentState extends State<_ProfileScreenContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header Section
              Column(
                children: [
                  // Profile Picture
                  Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(57),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(57),
                            child: profileProvider.profile?.photoUrl != null
                                ? Image.network(
                                    profileProvider.profile!.photoUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primaryBlue,
                                  ),
                          ),
                        ),
                      ),
                      // Online/Status indicator
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: profileProvider.isProfileComplete 
                                ? AppColors.success 
                                : AppColors.warning,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            profileProvider.isProfileComplete ? Icons.check : Icons.edit,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Name and Email
                  Text(
                    profileProvider.profile?.fullName ?? 'Complete Your Profile',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profileProvider.profile?.email ?? 'Add your email',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Menu Items
              Column(
                children: [
                  // My Subscriptions
                  _buildMenuItem(
                    icon: Icons.home,
                    title: 'My Subscriptions',
                    color: AppColors.error,
                    badgeCount: 1,
                    onTap: () {
                      // TODO: Navigate to subscriptions page
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Profile Edit
                  _buildMenuItem(
                    icon: Icons.edit,
                    title: 'Profile Edit',
                    color: AppColors.textSecondary,
                    onTap: () {
                      context.push(RoutePaths.profileDetails);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Settings
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    color: AppColors.textSecondary,
                    onTap: () {
                      context.push(RoutePaths.settings);
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // My Wallet
                  _buildMenuItem(
                    icon: Icons.account_balance_wallet,
                    title: 'My Wallet',
                    color: AppColors.textSecondary,
                    onTap: () {
                      // TODO: Navigate to wallet page
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Help Center
                  _buildMenuItem(
                    icon: Icons.help_center,
                    title: 'Help Center',
                    color: AppColors.textSecondary,
                    onTap: () {
                      // TODO: Navigate to help center page
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    int? badgeCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.shadowDark.withValues(alpha: 0.3)
                : AppColors.shadowLight.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon with colored background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      // Badge for notifications
                      if (badgeCount != null && badgeCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '$badgeCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}