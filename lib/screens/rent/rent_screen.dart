import 'package:flutter/material.dart';
import '../../models/models.dart' hide State;
import '../../services/filter_service.dart';
import '../../services/featured_service.dart';
import '../../themes/app_colour.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/rent_item_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/filter_modal.dart';

class RentScreen extends StatefulWidget {
  final Map<String, String>? searchParams;

  const RentScreen({super.key, this.searchParams});

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
    _initializeFiltersFromSearchParams();
    _loadRooms();
  }

  void _initializeFiltersFromSearchParams() {
    if (widget.searchParams != null && widget.searchParams!.isNotEmpty) {
      // Convert search parameters to RoomFilterParams
      final params = widget.searchParams!;

      final searchFilters = RoomFilterParams(
        roomType: params['roomType'] ?? 'any',
        maxOccupancy: params['occupancy'] != null
            ? _parseOccupancyFromString(params['occupancy']!)
            : null,
        maxPrice: params['maxPrice'] != null
            ? double.tryParse(params['maxPrice']!)
            : null,
      );

      _currentFilters = searchFilters;
    }
  }

  int? _parseOccupancyFromString(String occupancyString) {
    // Convert display strings back to numbers
    // e.g., "1 Person" -> 1, "2 People" -> 2, "4+ People" -> 4
    if (occupancyString.contains('1 Person')) return 1;
    if (occupancyString.contains('2 People')) return 2;
    if (occupancyString.contains('3 People')) return 3;
    if (occupancyString.contains('4')) return 4;
    return null;
  }

  Future<void> _loadRooms([RoomFilterParams? filters]) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use provided filters or current filters
      final filtersToUse = filters ?? _currentFilters;

      // Use featured priority service for better room sorting (featured first, then popular, then regular)
      final rooms = await FeaturedService.getRoomsWithFeaturedPriority(
        limit: 50,
        cityId: filtersToUse.cityId != 'any' ? filtersToUse.cityId : null,
        roomType: filtersToUse.roomType != 'any'
            ? RoomType.fromString(filtersToUse.roomType)
            : null,
        maxFee: filtersToUse.maxPrice,
      );

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
        pageBuilder: (context, animation, secondaryAnimation) => FilterModal(
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