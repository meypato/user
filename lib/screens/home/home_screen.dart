import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/bottom_navigation.dart';
import '../../themes/app_colour.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedRoomType = 'Any';
  String _selectedCity = 'Itanagar';
  double _priceRange = 15000;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black,
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 8.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image with Blur
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/icons/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 80),
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                        maxHeight: 580,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildMainContent(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildMainContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowMedium,
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Section
          _buildHeaderSection(),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryBlue.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Location Section
          _buildLocationSection(),

          // Divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryBlue.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Search Section
          Expanded(child: _buildSearchSection()),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Logo
        Container(
          width: 200,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                'assets/icons/logoside.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Description
        Text(
          'Arunachal\'s trusted rental platform with APST compatibility',
          style: TextStyle(
            color: AppColors.getTextSecondary(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryBlue.withValues(alpha: 0.08)
            : AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.primaryBlue.withValues(alpha: 0.3)
              : AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$_selectedCity, AP',
                  style: TextStyle(
                    color: AppColors.getTextPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: _showLocationPicker,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: isDark
                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                  : AppColors.primaryBlue.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryBlue.withValues(alpha: 0.15)
                    : AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.search,
                color: AppColors.primaryBlue,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Find Your Perfect Room',
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Form Fields
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                'Room Type',
                _selectedRoomType,
                ['Any', 'Single', 'Double', 'Triple', 'Studio'],
                (value) => setState(() => _selectedRoomType = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                'City',
                _selectedCity,
                ['Itanagar', 'Naharlagun', 'Pasighat', 'Tawang'],
                (value) => setState(() => _selectedCity = value!),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Price Range
        _buildPriceRange(),

        const SizedBox(height: 24),

        // Search Button
        _buildSearchButton(),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.getTextPrimary(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDarkSecondary
                : AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.getBorder(isDark),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.getTextSecondary(isDark),
                size: 18,
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRange() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Price Range',
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '₹${_priceRange.toInt()}/mo',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryBlue,
            inactiveTrackColor: AppColors.getBorder(isDark),
            thumbColor: AppColors.primaryBlue,
            overlayColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: _priceRange,
            min: 2000,
            max: 30000,
            divisions: 28,
            onChanged: (value) => setState(() => _priceRange = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹2K',
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDark),
                  fontSize: 11,
                ),
              ),
              Text(
                '₹30K',
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDark),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.primaryGradientDark : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () => context.go('/rent'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_rounded, size: 18),
            const SizedBox(width: 10),
            const Text(
              'Search Rooms',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.getCardBackground(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.getBorder(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Your City',
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            ...['Itanagar', 'Naharlagun', 'Pasighat', 'Tawang'].map(
              (city) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: _selectedCity == city
                      ? AppColors.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    city,
                    style: TextStyle(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: _selectedCity == city
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: _selectedCity == city
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.primaryBlue,
                        )
                      : null,
                  onTap: () {
                    setState(() => _selectedCity = city);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}