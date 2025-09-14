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
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: SafeArea(
        child: Container(
          height: 60, // Much more compact
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: isDark 
                    ? AppColors.shadowDark.withValues(alpha: 0.3)
                    : AppColors.shadowLight.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  icon: Icons.bed_outlined,
                  label: 'Rooms',
                  index: 1,
                  isSelected: currentIndex == 1,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.apartment_outlined,
                  label: 'Building',
                  index: 2,
                  isSelected: currentIndex == 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.favorite_outline,
                  label: 'Favorites',
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
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(context, index),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected
                  ? (isDark
                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.2))
                  : Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with simpler design
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? _getFilledIcon(icon) : icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? (isDark ? AppColors.primaryBlue : Colors.white)
                        : (isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.7)),
                    size: 22,
                  ),
                ),
                const SizedBox(height: 2),
                // Compact label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? AppColors.primaryBlue : Colors.white)
                        : (isDark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.6)),
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(label),
                ),
                // No dots - removed completely!
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
      case 1: // Rooms
        context.go(RoutePaths.rent);
        break;
      case 2: // Building
        context.go(RoutePaths.building);
        break;
      case 3: // Favorites
        context.go(RoutePaths.favorites);
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
      case Icons.bed_outlined:
        return Icons.bed;
      case Icons.apartment_outlined:
        return Icons.apartment;
      case Icons.favorite_outline:
        return Icons.favorite;
      case Icons.person_outline:
        return Icons.person;
      default:
        return outlineIcon;
    }
  }
}