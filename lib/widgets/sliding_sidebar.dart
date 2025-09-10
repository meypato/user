import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../themes/theme_provider.dart';
import '../themes/app_colour.dart';

class SlidingSidebar extends StatefulWidget {
  final Widget child;
  final Function(String)? onNavigate;
  final int currentBottomIndex;

  const SlidingSidebar({
    super.key,
    required this.child,
    this.onNavigate,
    this.currentBottomIndex = 0,
  });

  @override
  State<SlidingSidebar> createState() => _SlidingSidebarState();
}

class _SlidingSidebarState extends State<SlidingSidebar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleSidebar() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void closeSidebar() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _animationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Sidebar
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -280 + (280 * _slideAnimation.value),
                  0,
                ),
                child: Container(
                  width: 280,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: theme.brightness == Brightness.dark
                          ? [
                              AppColors.backgroundDark,
                              AppColors.backgroundDarkSecondary,
                              AppColors.surfaceDark,
                            ]
                          : [
                              AppColors.backgroundSecondary,
                              AppColors.backgroundLight,
                              AppColors.surfaceLight,
                            ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.shadowDark
                            : AppColors.shadowMedium,
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        // Beautiful Profile Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // Profile Avatar with gradient border
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue,
                                      AppColors.primaryBlueDark,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Container(
                                  width: 74,
                                  height: 74,
                                  decoration: BoxDecoration(
                                    color: theme.brightness == Brightness.dark
                                        ? AppColors.surfaceDark
                                        : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(37),
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    size: 36,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Find Your Home',
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Tenant',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Navigation Items
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _SidebarItem(
                                icon: Icons.search,
                                title: 'Search Rentals',
                                isSelected: widget.currentBottomIndex == 0,
                                onTap: () {
                                  widget.onNavigate?.call('home');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.apartment_outlined,
                                title: 'Properties',
                                isSelected: widget.currentBottomIndex == 1,
                                onTap: () {
                                  widget.onNavigate?.call('properties');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.favorite_outline,
                                title: 'Favorites',
                                isSelected: widget.currentBottomIndex == 2,
                                onTap: () {
                                  widget.onNavigate?.call('favorites');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.location_on_outlined,
                                title: 'Near Me',
                                isSelected: widget.currentBottomIndex == 3,
                                onTap: () {
                                  widget.onNavigate?.call('nearby');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.person_outline,
                                title: 'My Profile',
                                isSelected: widget.currentBottomIndex == 4,
                                onTap: () {
                                  widget.onNavigate?.call('profile');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                onTap: () {
                                  widget.onNavigate?.call('notification');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.settings_outlined,
                                title: 'Settings',
                                onTap: () {
                                  widget.onNavigate?.call('settings');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                onTap: () {
                                  widget.onNavigate?.call('help');
                                  closeSidebar();
                                },
                              ),
                              _SidebarItem(
                                icon: Icons.logout_outlined,
                                title: 'Logout',
                                onTap: () async {
                                  await AuthService.signOut();
                                },
                              ),
                            ],
                          ),
                        ),
                        // Theme Toggle at Bottom
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Dark Mode',
                                style: TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                                  return Switch(
                                    value: themeProvider.isDarkMode,
                                    onChanged: (value) {
                                      themeProvider.toggleTheme();
                                    },
                                    activeColor: AppColors.primaryBlue,
                                    inactiveThumbColor: theme.brightness == Brightness.dark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    inactiveTrackColor: theme.brightness == Brightness.dark
                                        ? AppColors.surfaceDark
                                        : AppColors.surfaceLight,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Main Content with slide animation
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(280 * _slideAnimation.value, 0),
                child: Stack(
                  children: [
                    // Main content
                    widget.child,
                    // Overlay when sidebar is open
                    if (_isOpen)
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return GestureDetector(
                            onTap: closeSidebar,
                            child: Container(
                              color: Colors.black.withValues(alpha: _fadeAnimation.value),
                            ),
                          );
                        },
                      ),
                    // Menu button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.shadowDark
                                  : AppColors.shadowMedium,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: toggleSidebar,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _isOpen ? Icons.close : Icons.menu,
                              key: ValueKey(_isOpen),
                              color: theme.brightness == Brightness.dark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.15),
                        AppColors.primaryBlue.withValues(alpha: 0.08),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: isSelected 
                  ? Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : null,
              boxShadow: isSelected 
                  ? [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : (theme.brightness == Brightness.dark
                            ? AppColors.surfaceDark.withValues(alpha: 0.3)
                            : AppColors.surfaceLight.withValues(alpha: 0.8)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected 
                        ? AppColors.primaryBlue
                        : (theme.brightness == Brightness.dark
                            ? AppColors.textSecondaryDark.withValues(alpha: 0.8)
                            : AppColors.textSecondary.withValues(alpha: 0.8)),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected 
                          ? AppColors.primaryBlue
                          : (theme.brightness == Brightness.dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: isSelected ? 0.1 : 0.0,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
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
}