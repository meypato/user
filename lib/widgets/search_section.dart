import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colour.dart';
import '../services/room_service.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  String _selectedRoomType = 'Any';
  String _selectedOccupancy = 'Any';
  double _priceRange = 15000;

  List<String> _roomTypes = ['Any'];
  List<String> _occupancyRanges = ['Any'];
  bool _isLoading = true;

  double _minPrice = 2000;
  double _maxPrice = 30000;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final roomTypes = await RoomService.getAvailableRoomTypes();
      final occupancyRanges = await RoomService.getAvailableOccupancyRanges();
      final priceRange = await RoomService.getAvailablePriceRange();

      setState(() {
        _roomTypes = roomTypes;
        _occupancyRanges = occupancyRanges;
        _minPrice = priceRange['min']!;
        _maxPrice = priceRange['max']!;
        // Set initial price range to middle value
        _priceRange = (_minPrice + _maxPrice) / 2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load search options: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

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
                _roomTypes,
                (value) => setState(() => _selectedRoomType = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdownField(
                'Occupancy',
                _selectedOccupancy,
                _occupancyRanges,
                (value) => setState(() => _selectedOccupancy = value!),
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
            value: _priceRange.clamp(_minPrice, _maxPrice),
            min: _minPrice,
            max: _maxPrice,
            divisions: (_maxPrice - _minPrice) ~/ 500, // 500 rupee steps
            onChanged: (value) => setState(() => _priceRange = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${(_minPrice / 1000).toStringAsFixed(0)}K',
                style: TextStyle(
                  color: AppColors.getTextSecondary(isDark),
                  fontSize: 11,
                ),
              ),
              Text(
                '₹${(_maxPrice / 1000).toStringAsFixed(0)}K',
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
        onPressed: _performSearch,
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

  void _performSearch() {
    // Build query parameters for search filters
    final Map<String, String> queryParams = {};

    // Only add non-default values to keep URL clean
    if (_selectedRoomType != 'Any') {
      queryParams['roomType'] = _selectedRoomType;
    }

    if (_selectedOccupancy != 'Any') {
      queryParams['occupancy'] = _selectedOccupancy;
    }

    // Always pass price if it's not the default middle value
    final defaultPrice = (_minPrice + _maxPrice) / 2;
    if (_priceRange != defaultPrice) {
      queryParams['maxPrice'] = _priceRange.toInt().toString();
    }

    // Navigate to rent screen with search parameters
    final uri = Uri(path: '/rent', queryParameters: queryParams.isNotEmpty ? queryParams : null);
    context.go(uri.toString());
  }

  Widget _buildLoadingState(bool isDark) {
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

        // Loading indicator
        Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading search options...',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}