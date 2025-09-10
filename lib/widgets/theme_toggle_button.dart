import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../themes/app_colour.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: themeProvider.isDarkMode 
                ? AppColors.primaryBlueLight 
                : AppColors.primaryBlue,
              width: 2,
            ),
            color: Colors.transparent,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () => themeProvider.toggleTheme(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      themeProvider.isDarkMode 
                        ? Icons.light_mode_rounded 
                        : Icons.dark_mode_rounded,
                      color: themeProvider.isDarkMode 
                        ? AppColors.primaryBlueLight 
                        : AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      themeProvider.isDarkMode ? 'Light' : 'Dark',
                      style: TextStyle(
                        color: themeProvider.isDarkMode 
                          ? AppColors.primaryBlueLight 
                          : AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ThemeToggleIconButton extends StatelessWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: themeProvider.isDarkMode 
                ? AppColors.primaryBlueLight 
                : AppColors.primaryBlue,
              width: 2,
            ),
            color: Colors.transparent,
          ),
          child: IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              themeProvider.isDarkMode 
                ? Icons.light_mode_rounded 
                : Icons.dark_mode_rounded,
              color: themeProvider.isDarkMode 
                ? AppColors.primaryBlueLight 
                : AppColors.primaryBlue,
            ),
            tooltip: themeProvider.isDarkMode 
              ? 'Switch to Light Mode' 
              : 'Switch to Dark Mode',
          ),
        );
      },
    );
  }
}