import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../themes/theme_provider.dart';
import '../themes/app_colour.dart';
import '../common/router.dart';
import '../providers/profile_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Column(
        children: [
          // Profile Header
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              final userName = profileProvider.profile?.fullName ?? 'User';
              return Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Profile Picture
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: profileProvider.profile?.photoUrl != null
                                ? Image.network(
                                    profileProvider.profile!.photoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.white,
                                        child: const Icon(
                                          Icons.person,
                                          size: 25,
                                          color: AppColors.primaryBlue,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.white,
                                    child: const Icon(
                                      Icons.person,
                                      size: 25,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // App name and welcome text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'MEYPATO',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Welcome, $userName',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Menu Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Main Navigation
                  ..._buildMenuItems([
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Home',
                      color: AppColors.primaryBlue,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RoutePaths.home);
                      },
                    ),
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.bed_outlined,
                      title: 'Rooms',
                      color: AppColors.primaryBlue,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RoutePaths.rent);
                      },
                    ),
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.apartment_outlined,
                      title: 'Building',
                      color: AppColors.primaryBlue,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RoutePaths.building);
                      },
                    ),
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Profile',
                      color: AppColors.primaryBlue,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RoutePaths.profile);
                      },
                    ),
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.pop(context);
                        context.push(RoutePaths.settings);
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 12),
                  
                  // Secondary Navigation
                  ..._buildMenuItems([
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.favorite_outline,
                      title: 'Favorites',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RoutePaths.favorites);
                      },
                    ),
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Add notification route when screen is created
                      },
                    ),
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.support_agent_outlined,
                      title: 'Contact Us',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.pop(context);
                        context.go(RoutePaths.contact);
                      },
                    ),
                    _buildBeautifulMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      color: AppColors.textSecondary,
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Add help route when screen is created
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Bottom Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              children: [
                // Dark Mode Toggle
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                            ? AppColors.shadowDark.withValues(alpha: 0.1)
                            : AppColors.shadowLight.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: AppColors.textSecondary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Dark Mode',
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: themeProvider.isDarkMode,
                                onChanged: (value) {
                                  themeProvider.toggleTheme();
                                },
                                activeColor: AppColors.primaryBlue,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Logout
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark 
                            ? AppColors.shadowDark.withValues(alpha: 0.1)
                            : AppColors.shadowLight.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        await AuthService.signOut();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.logout,
                                color: AppColors.error,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Logout',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems(List<Widget> items) {
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: item,
    )).toList();
  }

  Widget _buildBeautifulMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.shadowDark.withValues(alpha: 0.1)
                : AppColors.shadowLight.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Icon with colored background
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}