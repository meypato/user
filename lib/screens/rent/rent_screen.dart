import 'package:flutter/material.dart';
import '../../models/models.dart' hide State;
import '../../services/filter_service.dart';
import '../../services/room_service.dart';
import '../../services/city_service.dart';
import '../../themes/app_colour.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/rent_item_card.dart';
import '../../widgets/app_drawer.dart';

class RentScreen extends StatefulWidget {
  const RentScreen({super.key});

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen> {
  List<Room> _rooms = [];
  bool _isLoading = true;
  String? _error;
  RoomFilterParams _currentFilters = RoomFilterParams();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms([RoomFilterParams? filters]) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use provided filters or current filters
      final filtersToUse = filters ?? _currentFilters;

      final rooms = await FilterService.getFilteredRooms(filtersToUse);

      setState(() {
        _rooms = rooms;
        _isLoading = false;
        if (filters != null) {
          _currentFilters = filters;
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Rooms',
          style: TextStyle(
            color: theme.brightness == Brightness.dark 
                ? AppColors.textPrimaryDark 
                : AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: theme.brightness == Brightness.dark 
              ? AppColors.textPrimaryDark 
              : AppColors.textPrimary,
        ),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Just Search Bar and Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Expanded(child: _buildUltraCompactSearchBar(theme)),
                  const SizedBox(width: 12),
                  _buildFilterButton(theme),
                ],
              ),
            ),
            
            // Content without horizontal padding
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      extendBody: true,
      bottomNavigationBar: const CustomBottomNavigation(
        currentIndex: 1, // Rent tab index
      ),
    );
  }


  Widget _buildUltraCompactSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: theme.iconTheme.color?.withValues(alpha: 0.6),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search rooms...',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showFilterModal(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.tune,
          color: theme.colorScheme.primary,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading rooms...',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRooms,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rooms.isEmpty) {
      return Center(
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
              'No rooms available',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new listings',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count with filter indicator
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 6),
          child: Row(
            children: [
              Text(
                '${_rooms.length} available',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_alt,
                        size: 10,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Filtered',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (_hasActiveFilters) ...[
                GestureDetector(
                  onTap: _clearFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear,
                          size: 12,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Clear',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Rooms list (items have their own horizontal padding)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 2, bottom: 100), // Content flows behind nav + scroll padding
            itemCount: _rooms.length,
            itemBuilder: (context, index) {
              return RentItemCard(
                room: _rooms[index],
                isFirst: index == 0,
                // Let RentItemCard handle navigation with its default onTap
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFilterModal(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => _FilterModal(
          onApplyFilters: (filters) {
            Navigator.of(context).pop();
            _loadRooms(filters);
          },
        ),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  bool get _hasActiveFilters {
    return _currentFilters.cityId != 'any' ||
           _currentFilters.roomType != 'any' ||
           _currentFilters.maxPrice != null ||
           _currentFilters.maxOccupancy != null ||
           _currentFilters.buildingType != 'any' ||
           _currentFilters.amenityIds.isNotEmpty;
  }

  void _clearFilters() {
    final clearedFilters = RoomFilterParams();
    _loadRooms(clearedFilters);
  }
}

class _FilterModal extends StatefulWidget {
  final Function(RoomFilterParams) onApplyFilters;

  const _FilterModal({required this.onApplyFilters});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<_FilterModal> {
  // Filter data - using same pattern as SearchSection
  List<String> _roomTypes = ['Any'];
  List<String> _cities = ['Any'];
  List<String> _occupancyRanges = ['Any'];
  List<City> _cityModels = []; // Store full city objects for ID mapping

  double _minPrice = 2000;
  double _maxPrice = 30000;

  // Selected values
  String _selectedRoomType = 'Any';
  String _selectedCity = 'Any';
  int _selectedOccupancy = 1; // Default to 1
  double _currentPriceRange = 5000;

  // Loading states
  bool _isLoadingFilters = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    try {
      setState(() {
        _isLoadingFilters = true;
        _error = null;
      });

      // Load all filter data in parallel
      final results = await Future.wait([
        RoomService.getAvailableRoomTypes(),
        RoomService.getAvailableOccupancyRanges(),
        RoomService.getAvailablePriceRange(),
        CityService.getArunachalCities(),
      ]);

      final roomTypes = results[0] as List<String>;
      final occupancyRanges = results[1] as List<String>;
      final priceRange = results[2] as Map<String, double>;
      final cityModels = results[3] as List<City>;

      // If no room types are available from database, show all enum types
      final finalRoomTypes = roomTypes.length <= 1
          ? ['Any', 'Single', 'Double', 'Shared', 'Private']
          : roomTypes;

      // Convert City models to string list with "Any" at the beginning
      final cities = ['Any', ...cityModels.map((city) => city.name)];

      setState(() {
        _roomTypes = finalRoomTypes;
        _occupancyRanges = occupancyRanges;
        _cities = cities;
        _cityModels = cityModels; // Store full city objects
        _minPrice = priceRange['min']!;
        _maxPrice = priceRange['max']!;
        _currentPriceRange = (_minPrice + _maxPrice) / 2; // Set to middle of range
        _isLoadingFilters = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingFilters = false;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedRoomType = 'Any';
      _selectedCity = 'Any';
      _selectedOccupancy = 1;
      _currentPriceRange = (_minPrice + _maxPrice) / 2;
    });
  }

  void _applyFilters() {
    // Find the city ID if a specific city is selected
    String cityId = 'any';
    if (_selectedCity.toLowerCase() != 'any') {
      final selectedCityModel = _cityModels.where((city) => city.name == _selectedCity).firstOrNull;
      if (selectedCityModel != null) {
        cityId = selectedCityModel.id;
      }
    }

    final filters = RoomFilterParams(
      roomType: _selectedRoomType.toLowerCase() == 'any' ? 'any' : _selectedRoomType.toLowerCase(),
      cityId: cityId,
      maxPrice: _currentPriceRange,
      maxOccupancy: _selectedOccupancy > 1 ? _selectedOccupancy : null,
    );
    widget.onApplyFilters(filters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Filter Rooms',
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Options
            Expanded(
              child: _isLoadingFilters
                  ? _buildLoadingState(theme)
                  : _error != null
                      ? _buildErrorState(theme)
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                    // Price Range
                    _buildFilterSection(
                      'Price Range',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Up to ₹${_currentPriceRange.toInt()}',
                                style: TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'per month',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primaryBlue,
                              thumbColor: AppColors.primaryBlue,
                              overlayColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                            ),
                            child: Slider(
                              value: _currentPriceRange,
                              min: _minPrice,
                              max: _maxPrice,
                              divisions: ((_maxPrice - _minPrice) / 500).round(),
                              onChanged: (value) => setState(() => _currentPriceRange = value),
                            ),
                          ),
                        ],
                      ),
                      theme,
                    ),

                    const SizedBox(height: 24),

                    // Room Type
                    _buildFilterSection(
                      'Room Type',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _isLoadingFilters
                            ? [_buildLoadingChip(theme)]
                            : _roomTypes.map(
                                (type) => _buildChip(type, _selectedRoomType == type, () {
                                  setState(() => _selectedRoomType = type);
                                }, theme),
                              ).toList(),
                      ),
                      theme,
                    ),

                    const SizedBox(height: 24),

                    // City
                    _buildFilterSection(
                      'City',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _isLoadingFilters
                            ? [_buildLoadingChip(theme)]
                            : _cities.map(
                                (city) => _buildChip(city, _selectedCity == city, () {
                                  setState(() => _selectedCity = city);
                                }, theme),
                              ).toList(),
                      ),
                      theme,
                    ),

                    const SizedBox(height: 24),

                    // Occupancy
                    _buildFilterSection(
                      'Occupancy',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _isLoadingFilters
                            ? [_buildLoadingChip(theme)]
                            : _occupancyRanges.map(
                                (occupancy) => _buildChip(occupancy, _selectedOccupancy.toString() == occupancy.replaceAll(RegExp(r'[^0-9]'), ''), () {
                                  final occupancyNumber = int.tryParse(occupancy.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
                                  setState(() => _selectedOccupancy = occupancyNumber);
                                }, theme),
                              ).toList(),
                      ),
                      theme,
                    ),

                            ],
                          ),
                        ),
            ),

            // Apply Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryBlue),
          const SizedBox(height: 16),
          Text(
            'Loading filter options...',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load filters',
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadFilterOptions,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}