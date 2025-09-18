import 'package:flutter/material.dart';
import '../models/models.dart' hide State;
import '../services/city_service.dart';
import '../services/profile_service.dart';
import '../services/building_filter_service.dart';
import '../themes/app_colour.dart';

class BuildingFilterModal extends StatefulWidget {
  final Function(BuildingFilterParams) onApplyFilters;

  const BuildingFilterModal({super.key, required this.onApplyFilters});

  @override
  State<BuildingFilterModal> createState() => _BuildingFilterModalState();
}

class _BuildingFilterModalState extends State<BuildingFilterModal> {
  // Filter data
  List<String> _buildingTypes = ['Any'];
  List<String> _cities = ['Any'];
  List<City> _cityModels = []; // Store full city objects for ID mapping

  // Selected values
  String _selectedBuildingType = 'Any';
  String _selectedCity = 'Any';
  double _selectedDistance = 0.0; // 0 = Any distance

  // Location state
  String? _userCityName;
  double? _userLatitude;
  double? _userLongitude;

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

      // Load all filter data and user profile in parallel
      final results = await Future.wait([
        BuildingFilterService.getAvailableBuildingTypes(),
        BuildingFilterService.getAvailableCities(),
        CityService.getArunachalCities(),
        ProfileService.getCurrentUserProfile(), // Get user's location
      ]);

      final buildingTypeOptions = results[0] as List<FilterOption>;
      final cityOptions = results[1] as List<FilterOption>;
      final cityModels = results[2] as List<City>;
      final userProfile = results[3] as Profile?;

      // Get user's city information and location
      String? userCityName;
      double? userLatitude;
      double? userLongitude;

      if (userProfile?.cityId != null) {
        userCityName = await CityService.getCityName(userProfile!.cityId);
        // TODO: In a real app, you might get coordinates from the profile or geocoding
        // For now, we'll leave them null which will disable distance filtering
        // userLatitude = userProfile.latitude;
        // userLongitude = userProfile.longitude;
      }

      // Convert FilterOptions to string lists
      final buildingTypes = ['Any', ...buildingTypeOptions.skip(1).map((opt) => opt.label)];
      final cities = ['Any', ...cityOptions.skip(1).map((opt) => opt.label)];

      // Note: Distance ranges are handled by the slider, no need to preload

      setState(() {
        _buildingTypes = buildingTypes;
        _cities = cities;
        _cityModels = cityModels;
        _userCityName = userCityName;
        _userLatitude = userLatitude;
        _userLongitude = userLongitude;
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
      _selectedBuildingType = 'Any';
      _selectedCity = 'Any';
      _selectedDistance = 0.0;
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

    final filters = BuildingFilterParams(
      buildingType: _selectedBuildingType.toLowerCase() == 'any'
          ? 'any'
          : BuildingType.values
              .firstWhere((type) => type.displayName == _selectedBuildingType)
              .name,
      cityId: cityId,
      maxDistance: _selectedDistance > 0 ? _selectedDistance : null,
      userLatitude: _userLatitude,
      userLongitude: _userLongitude,
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
                      'Filter Buildings',
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.error.withValues(alpha: 0.15)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            color: AppColors.error,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reset',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location Section - At Top with Dual UI
                              _buildLocationSection(theme),

                              const SizedBox(height: 16),

                              // Distance Section - Beautiful & Compact
                              if (_userLatitude != null && _userLongitude != null)
                                _buildDistanceSection(theme),

                              if (_userLatitude != null && _userLongitude != null)
                                const SizedBox(height: 16),

                              // Building Type - Full Width Layout with Vertical Chips
                              _buildVerticalFilterSection(
                                'Building Type',
                                Icons.apartment,
                                _isLoadingFilters
                                    ? [_buildLoadingChip(theme)]
                                    : _buildingTypes.map(
                                        (type) => _buildFullWidthChip(
                                          type,
                                          _selectedBuildingType == type,
                                          () => setState(() => _selectedBuildingType = type),
                                          theme,
                                        ),
                                      ).toList(),
                                theme,
                              ),
                            ],
                          ),
                        ),
            ),

            // Apply Button - Enhanced
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _applyFilters,
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
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.success.withValues(alpha: 0.12),
                  AppColors.success.withValues(alpha: 0.04),
                ]
              : [
                  AppColors.success.withValues(alpha: 0.06),
                  AppColors.success.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.success,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // User's Current Location (if available)
          if (_userCityName != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: AppColors.success,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Your Location',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildCompactChip(_userCityName!, _selectedCity == _userCityName, () {
                    setState(() => _selectedCity = _userCityName!);
                  }, theme),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Other Locations
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDarkSecondary.withValues(alpha: 0.3)
                  : AppColors.backgroundSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.2)
                    : AppColors.textSecondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.explore,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Other Locations',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _isLoadingFilters
                      ? [_buildLoadingChip(theme)]
                      : _cities.where((city) => city != _userCityName).map(
                          (city) => _buildCompactChip(city, _selectedCity == city, () {
                            setState(() => _selectedCity = city);
                          }, theme),
                        ).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.orange.withValues(alpha: 0.15),
                  Colors.orange.withValues(alpha: 0.05),
                ]
              : [
                  Colors.orange.withValues(alpha: 0.08),
                  Colors.orange.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.near_me,
                  color: Colors.orange,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Distance',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _selectedDistance > 0
                      ? 'Within ${_selectedDistance.toInt()} km'
                      : 'Any Distance',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distance Range Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.orange.withValues(alpha: 0.2),
              thumbColor: Colors.white,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 2,
                pressedElevation: 4,
              ),
              overlayColor: Colors.orange.withValues(alpha: 0.1),
              trackHeight: 4,
            ),
            child: Slider(
              value: _selectedDistance,
              min: 0.0,
              max: 50.0,
              divisions: 50,
              onChanged: (value) => setState(() => _selectedDistance = value),
            ),
          ),

          // Min/Max Distance Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Any',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '50 km',
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalFilterSection(String title, IconData icon, List<Widget> chips, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.textSecondaryDark.withValues(alpha: 0.15)
              : AppColors.textSecondary.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.05)
                : AppColors.primaryBlue.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryBlue,
                  size: 12,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            children: chips.map((chip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: chip,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthChip(String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : theme.colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withValues(alpha: 0.2),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactChip(String label, bool isSelected, VoidCallback onTap, ThemeData theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              : theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
            fontSize: 12,
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