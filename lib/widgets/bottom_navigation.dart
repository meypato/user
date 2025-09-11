import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colour.dart';
import '../common/router.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.brightness == Brightness.dark
              ? [
                  AppColors.backgroundDark.withValues(alpha: 0.95),
                  AppColors.backgroundDark,
                ]
              : [
                  AppColors.backgroundSecondary.withValues(alpha: 0.95),
                  AppColors.backgroundSecondary,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? AppColors.shadowDark
                : AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? AppColors.borderDark.withValues(alpha: 0.2)
                : AppColors.borderLight.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.search,
                label: 'Home',
                index: 0,
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.apartment_outlined,
                label: 'Rent',
                index: 1,
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.favorite_outline,
                label: 'Favorites',
                index: 2,
                isSelected: currentIndex == 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.location_on_outlined,
                label: 'Near Me',
                index: 3,
                isSelected: currentIndex == 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                label: 'Profile',
                index: 4,
                isSelected: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(context, index),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected 
                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle for selected state
                    if (isSelected)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    // Icon
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected ? _getFilledIcon(icon) : icon,
                        key: ValueKey(isSelected),
                        color: isSelected 
                            ? AppColors.primaryBlue
                            : (theme.brightness == Brightness.dark
                                ? AppColors.textSecondaryDark.withValues(alpha: 0.8)
                                : AppColors.textSecondary.withValues(alpha: 0.8)),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected 
                        ? AppColors.primaryBlue
                        : (theme.brightness == Brightness.dark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                            : AppColors.textSecondary.withValues(alpha: 0.7)),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: isSelected ? 0.1 : 0.0,
                  ),
                  child: Text(label),
                ),
                // Active indicator dot
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 4 : 0,
                  height: isSelected ? 4 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // If there's a custom onTap handler, use it (for backward compatibility)
    if (onTap != null) {
      onTap!(index);
      return;
    }
    
    // Otherwise, handle navigation with GoRouter
    switch (index) {
      case 0: // Home/Search
        context.go(RoutePaths.home);
        break;
      case 1: // Rent
        context.go(RoutePaths.rent);
        break;
      case 2: // Favorites
        // TODO: Add favorites route when screen is created
        break;
      case 3: // Near Me
        // TODO: Add nearby route when screen is created
        break;
      case 4: // Profile
        context.go(RoutePaths.profile);
        break;
    }
  }

  IconData _getFilledIcon(IconData outlineIcon) {
    switch (outlineIcon) {
      case Icons.search:
        return Icons.search;
      case Icons.apartment_outlined:
        return Icons.apartment;
      case Icons.favorite_outline:
        return Icons.favorite;
      case Icons.location_on_outlined:
        return Icons.location_on;
      case Icons.person_outline:
        return Icons.person;
      default:
        return outlineIcon;
    }
  }
}