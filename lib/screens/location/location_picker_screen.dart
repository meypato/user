import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colour.dart';
import '../../models/reference_models.dart' show City;
import '../../services/city_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final String? selectedCityId;

  const LocationPickerScreen({
    super.key,
    this.selectedCityId,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late TextEditingController _searchController;
  List<City> _filteredCities = [];
  List<City> _allCities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterCities);
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await CityService.getArunachalCities();
      setState(() {
        _allCities = cities;
        _filteredCities = cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load cities: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCities = _allCities
          .where((city) => city.name.toLowerCase().contains(query))
          .toList();
    });
  }

  void _selectCity(City city) {
    context.pop(city.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDarkSecondary : AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Your City',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: isDark ? AppColors.backgroundDarkSecondary : AppColors.primaryBlue,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: AppColors.getTextPrimary(isDark),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search cities in Arunachal Pradesh...',
                  hintStyle: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.getTextSecondary(isDark),
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // Results Section
          Expanded(
            child: _isLoading
                ? _buildLoadingState(isDark)
                : _filteredCities.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      final isSelected = widget.selectedCityId == city.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardBackgroundDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primaryBlue,
                                  width: 2,
                                )
                              : Border.all(
                                  color: AppColors.getBorder(isDark),
                                  width: 1,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                              blurRadius: isSelected ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : isDark
                                      ? AppColors.primaryBlue.withValues(alpha: 0.15)
                                      : AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isSelected ? Icons.check_circle : Icons.location_city,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            city.name,
                            style: TextStyle(
                              color: AppColors.getTextPrimary(isDark),
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Arunachal Pradesh',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(isDark),
                              fontSize: 14,
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Selected',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.getTextSecondary(isDark),
                                  size: 16,
                                ),
                          onTap: () => _selectCity(city),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading cities...',
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primaryBlue.withValues(alpha: 0.15)
                    : AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                color: AppColors.primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No cities found',
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with a different term or check your spelling',
              style: TextStyle(
                color: AppColors.getTextSecondary(isDark),
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}