import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colour.dart';
import '../../providers/profile_provider.dart';
import '../../common/router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: SafeArea(
            child: Column(
              children: [
                // Header with back button and title
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark 
                              ? AppColors.surfaceDark.withValues(alpha: 0.8)
                              : AppColors.surfaceLight.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.arrow_back,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40), // Balance the back button
                    ],
                  ),
                ),

                // Profile Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
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
                          // Online/Status indicator (similar to the red dot in the image)
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
                ),

                const SizedBox(height: 40),

                // Menu Items
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
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

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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