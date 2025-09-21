import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/models.dart' hide State;
import '../../services/building_filter_service.dart';
import '../../services/location_service.dart';
import '../../themes/app_colour.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/building_item_card.dart';
import '../../widgets/building_filter_modal.dart';

class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  List<Building> _buildings = [];
  bool _isLoading = true;
  String? _error;
  BuildingFilterParams _currentFilters = BuildingFilterParams();

  // Nearby functionality state
  bool _isNearbyMode = false;
  bool _isGettingLocation = false;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  Future<void> _loadBuildings([BuildingFilterParams? filters]) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use provided filters or current filters
      final filtersToUse = filters ?? _currentFilters;

      // Load buildings from BuildingFilterService
      final buildings = await BuildingFilterService.getFilteredBuildings(filtersToUse);

      setState(() {
        _buildings = buildings;
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
          'Buildings',
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
        actions: [
          _buildNearbyButton(theme),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar and Filter
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
        currentIndex: 2, // Building tab index
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
              'Search buildings...',
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
              'Loading buildings...',
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
              onPressed: _loadBuildings,
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

    if (_buildings.isEmpty) {
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
                Icons.apartment_outlined,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No buildings available',
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
                _isNearbyMode
                    ? '${_buildings.length} nearby buildings'
                    : '${_buildings.length} available',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_isNearbyMode) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.near_me,
                        size: 10,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Nearby Mode',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_hasActiveFilters) ...[
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

        // Buildings grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _buildings.length,
            itemBuilder: (context, index) {
              final building = _buildings[index];
              final distance = _getBuildingDistance(building);

              return BuildingItemCard(
                building: building,
                distance: distance,
              );
            },
          ),
        ),
      ],
    );
  }

  bool get _hasActiveFilters {
    return _currentFilters.cityId != 'any' ||
           _currentFilters.buildingType != 'any' ||
           _currentFilters.maxDistance != null ||
           _currentFilters.pincode != 'any';
  }

  void _clearFilters() {
    final clearedFilters = BuildingFilterParams();
    _loadBuildings(clearedFilters);
  }

  void _showFilterModal(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BuildingFilterModal(
          onApplyFilters: (filters) {
            Navigator.of(context).pop();
            _loadBuildings(filters);
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

  /// Build the nearby toggle button for the app bar
  Widget _buildNearbyButton(ThemeData theme) {
    return GestureDetector(
      onTap: _isGettingLocation ? null : _toggleNearbyMode,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isNearbyMode
              ? AppColors.primaryBlue
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isNearbyMode
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isGettingLocation) ...[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _isNearbyMode ? Colors.white : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 6),
            ] else ...[
              Icon(
                _isNearbyMode ? Icons.near_me : Icons.near_me_outlined,
                color: _isNearbyMode ? Colors.white : AppColors.primaryBlue,
                size: 16,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              _isGettingLocation
                  ? 'Getting Location...'
                  : _isNearbyMode
                      ? 'Nearby'
                      : 'Nearby',
              style: TextStyle(
                color: _isNearbyMode ? Colors.white : AppColors.primaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggle nearby mode on/off
  Future<void> _toggleNearbyMode() async {
    if (_isNearbyMode) {
      // Turn off nearby mode
      setState(() {
        _isNearbyMode = false;
        _userPosition = null;
      });
      // Reload regular buildings
      await _loadBuildings();
    } else {
      // Turn on nearby mode
      await _enableNearbyMode();
    }
  }

  /// Enable nearby mode by getting user location
  Future<void> _enableNearbyMode() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check if location services are enabled
      if (!await LocationService.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled. Please enable location services in your device settings.');
      }

      // Get current position
      final position = await LocationService.getCurrentPosition(
        accuracy: LocationAccuracy.high,
      );

      if (position != null) {
        setState(() {
          _userPosition = position;
          _isNearbyMode = true;
          _isGettingLocation = false;
        });

        // Load nearby buildings
        await _loadNearbyBuildings();
      } else {
        throw Exception('Could not get your location. Please check your location permissions.');
      }
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });

      // Show error dialog
      if (mounted) {
        _showLocationErrorDialog(e.toString());
      }
    }
  }

  /// Load nearby buildings sorted by distance
  Future<void> _loadNearbyBuildings() async {
    if (_userPosition == null) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get nearby buildings with distance
      final nearbyBuildings = await BuildingFilterService.getNearbyBuildings(
        userLatitude: _userPosition!.latitude,
        userLongitude: _userPosition!.longitude,
        maxDistance: 50.0, // 50km max range
        cityId: _currentFilters.cityId != 'any' ? _currentFilters.cityId : null,
        buildingType: _currentFilters.buildingType != 'any' ? _currentFilters.buildingType : null,
      );

      setState(() {
        _buildings = nearbyBuildings.map((bwd) => bwd.building).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Show location error dialog with helpful actions
  void _showLocationErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Access Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error),
            const SizedBox(height: 16),
            const Text(
              'To find nearby buildings, we need access to your location. Please:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text('• Enable location services on your device'),
            const Text('• Grant location permission to this app'),
            const Text('• Make sure you have a GPS signal'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await LocationService.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _enableNearbyMode();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Get distance for a building (used in UI display)
  String? _getBuildingDistance(Building building) {
    if (!_isNearbyMode || _userPosition == null || !building.hasLocation) {
      return null;
    }
    return building.getFormattedDistance(
      _userPosition!.latitude,
      _userPosition!.longitude,
    );
  }
}

