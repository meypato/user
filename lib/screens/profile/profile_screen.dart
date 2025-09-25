import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colour.dart';
import '../../providers/profile_provider.dart';
import '../../common/router.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/profile_completion_banner.dart';

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
          drawer: const AppDrawer(),
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            elevation: 0,
            title: Text(
              'Profile',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconTheme: IconThemeData(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top padding for status bar
                SizedBox(height: MediaQuery.of(context).padding.top),

                // Profile Completion Banner
                if (profileProvider.hasProfile && !profileProvider.isProfileComplete && profileProvider.profile != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ProfileCompletionBanner(profile: profileProvider.profile!),
                  ),

                // Compact Profile Header Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.primaryBlue.withValues(alpha: 0.15), AppColors.primaryBlue.withValues(alpha: 0.05)]
                          : [AppColors.primaryBlue.withValues(alpha: 0.08), AppColors.primaryBlue.withValues(alpha: 0.02)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Compact Profile Picture
                      Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                              ),
                              borderRadius: BorderRadius.circular(35),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(33),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(33),
                                child: profileProvider.profile?.photoUrl != null
                                    ? Image.network(
                                        profileProvider.profile!.photoUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: AppColors.primaryBlue,
                                      ),
                              ),
                            ),
                          ),
                          // Compact Status indicator
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: profileProvider.isProfileComplete
                                    ? AppColors.success
                                    : AppColors.warning,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                profileProvider.isProfileComplete ? Icons.check : Icons.edit,
                                color: Colors.white,
                                size: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Compact Name and Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileProvider.profile?.fullName ?? 'Complete Your Profile',
                              style: TextStyle(
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileProvider.profile?.email ?? 'Add your email',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            // Status chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (profileProvider.isProfileComplete ? AppColors.success : AppColors.warning)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (profileProvider.isProfileComplete ? AppColors.success : AppColors.warning)
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                profileProvider.isProfileComplete ? 'Profile Complete' : 'Complete Profile',
                                style: TextStyle(
                                  color: profileProvider.isProfileComplete ? AppColors.success : AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Compact Menu Items Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Top Row: My Subscriptions and Profile Edit
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactMenuItem(
                              icon: Icons.home_filled,
                              title: 'My Subscriptions',
                              color: AppColors.error,
                              badgeCount: 1,
                              onTap: () {
                                // TODO: Navigate to subscriptions page
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactMenuItem(
                              icon: Icons.visibility_rounded,
                              title: 'View Profile',
                              color: AppColors.primaryBlue,
                              onTap: () {
                                context.push('/profile/view');
                              },
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Middle Row: Settings and My Wallet
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactMenuItem(
                              icon: Icons.settings_rounded,
                              title: 'Settings',
                              color: AppColors.warning,
                              onTap: () {
                                context.push(RoutePaths.settings);
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactMenuItem(
                              icon: Icons.account_balance_wallet_rounded,
                              title: 'My Wallet',
                              color: AppColors.success,
                              onTap: () {
                                // TODO: Navigate to wallet page
                              },
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Bottom Row: Help Center (single, centered)
                      _buildCompactMenuItem(
                        icon: Icons.help_center_rounded,
                        title: 'Help Center',
                        color: const Color(0xFF6B73FF),
                        onTap: () {
                          // TODO: Navigate to help center page
                        },
                        isDark: isDark,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
                // Bottom padding for floating navigation
                const SizedBox(height: 100),
                ],
              ),
            ),
          extendBody: true,
          bottomNavigationBar: const CustomBottomNavigation(
            currentIndex: 4, // Profile tab index
          ),
        );
      },
    );
  }

  Widget _buildCompactMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    int? badgeCount,
    bool isFullWidth = false,
  }) {
    return Container(
      height: 80, // Reduced from 85 to 80
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.surfaceDark,
                  AppColors.surfaceDark.withValues(alpha: 0.8),
                ]
              : [
                  AppColors.surfaceLight,
                  AppColors.surfaceLight.withValues(alpha: 0.9),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12), // Reduced from 16 to 12
            child: isFullWidth
                ? Row(
                    children: [
                      _buildIconContainer(icon, color, badgeCount),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: color.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                    children: [
                      _buildIconContainer(icon, color, badgeCount),
                      const SizedBox(height: 6), // Reduced from 8 to 6
                      Flexible( // Wrapped in Flexible to prevent overflow
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            fontSize: 11, // Reduced from 12 to 11
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color, int? badgeCount) {
    return Container(
      width: 36, // Reduced from 40 to 36
      height: 36, // Reduced from 40 to 36
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10), // Reduced from 12 to 10
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              icon,
              color: color,
              size: 18, // Reduced from 20 to 18
            ),
          ),
          // Badge for notifications
          if (badgeCount != null && badgeCount > 0)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 12, // Reduced from 14 to 12
                height: 12, // Reduced from 14 to 12
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(6), // Reduced from 7 to 6
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7, // Reduced from 8 to 7
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}