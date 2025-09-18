import 'dart:math' as dart_math;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class BuildingFilterService {
  static final _supabase = Supabase.instance.client;

  // Get available building types with counts for dropdown
  static Future<List<FilterOption>> getAvailableBuildingTypes() async {
    try {
      final response = await _supabase
          .from('buildings')
          .select('building_type')
          .eq('is_active', true);

      final Map<String, int> typeCounts = {};
      for (final building in response) {
        final buildingType = building['building_type'] as String;
        typeCounts[buildingType] = (typeCounts[buildingType] ?? 0) + 1;
      }

      final List<FilterOption> options = [
        FilterOption(value: 'any', label: 'Any Type', count: response.length),
      ];

      // Convert enum values to display names with counts
      for (final type in BuildingType.values) {
        final count = typeCounts[type.name] ?? 0;
        if (count > 0) {
          options.add(FilterOption(
            value: type.name,
            label: type.displayName,
            count: count,
          ));
        }
      }

      return options;
    } catch (e) {
      throw Exception('Failed to fetch building types: $e');
    }
  }

  // Get available cities in Arunachal Pradesh with building counts
  static Future<List<FilterOption>> getAvailableCities() async {
    try {
      final response = await _supabase
          .from('buildings')
          .select('''
            city_id,
            cities!inner(name)
          ''')
          .eq('is_active', true);

      final Map<String, CityData> cityCounts = {};

      for (final building in response) {
        final cityId = building['city_id'] as String;
        final cityName = building['cities']['name'] as String;

        if (cityCounts.containsKey(cityId)) {
          cityCounts[cityId]!.count++;
        } else {
          cityCounts[cityId] = CityData(
            id: cityId,
            name: cityName,
            count: 1,
          );
        }
      }

      final List<FilterOption> options = [
        FilterOption(value: 'any', label: 'Any City', count: response.length),
      ];

      // Sort cities by building count (descending)
      final sortedCities = cityCounts.values.toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      for (final city in sortedCities) {
        options.add(FilterOption(
          value: city.id,
          label: city.name,
          count: city.count,
        ));
      }

      return options;
    } catch (e) {
      throw Exception('Failed to fetch cities: $e');
    }
  }

  // Get available pincodes with building counts (optional advanced filter)
  static Future<List<FilterOption>> getAvailablePincodes() async {
    try {
      final response = await _supabase
          .from('buildings')
          .select('pincode')
          .eq('is_active', true)
          .not('pincode', 'is', null);

      final Map<String, int> pincodeCounts = {};
      for (final building in response) {
        final pincode = building['pincode'] as String;
        pincodeCounts[pincode] = (pincodeCounts[pincode] ?? 0) + 1;
      }

      final List<FilterOption> options = [
        FilterOption(value: 'any', label: 'Any Area', count: response.length),
      ];

      // Sort pincodes by building count (descending)
      final sortedPincodes = pincodeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedPincodes) {
        if (entry.value > 0) {
          options.add(FilterOption(
            value: entry.key,
            label: 'Area ${entry.key}',
            count: entry.value,
          ));
        }
      }

      return options;
    } catch (e) {
      throw Exception('Failed to fetch pincodes: $e');
    }
  }

  // Get buildings in proximity to user location (requires coordinates)
  static Future<List<FilterOption>> getAvailableDistanceRanges({
    double? userLatitude,
    double? userLongitude,
  }) async {
    try {
      if (userLatitude == null || userLongitude == null) {
        return [
          FilterOption(value: 0.0, label: 'Any Distance', count: 0),
        ];
      }

      final response = await _supabase
          .from('buildings')
          .select('latitude, longitude')
          .eq('is_active', true)
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);

      // Calculate distance ranges
      final List<double> distances = [];
      for (final building in response) {
        final lat = building['latitude'] as double;
        final lng = building['longitude'] as double;
        final distance = _calculateDistance(userLatitude, userLongitude, lat, lng);
        distances.add(distance);
      }

      distances.sort();

      final List<FilterOption> options = [
        FilterOption(value: 0.0, label: 'Any Distance', count: response.length),
      ];

      // Create distance range options
      final ranges = [1.0, 2.0, 5.0, 10.0, 20.0, 50.0];
      for (final range in ranges) {
        final count = distances.where((d) => d <= range).length;
        if (count > 0) {
          options.add(FilterOption(
            value: range,
            label: 'Within ${range.toInt()} km',
            count: count,
          ));
        }
      }

      return options;
    } catch (e) {
      throw Exception('Failed to fetch distance ranges: $e');
    }
  }

  // Apply filters to get filtered buildings
  static Future<List<Building>> getFilteredBuildings(BuildingFilterParams filters) async {
    try {
      var query = _supabase
          .from('buildings')
          .select('''
            *,
            cities!inner(name),
            states!inner(name)
          ''')
          .eq('is_active', true);

      // Apply city filter
      if (filters.cityId != 'any') {
        query = query.eq('city_id', filters.cityId);
      }

      // Apply building type filter
      if (filters.buildingType != 'any') {
        query = query.eq('building_type', filters.buildingType);
      }

      // Apply pincode filter
      if (filters.pincode != 'any') {
        query = query.eq('pincode', filters.pincode);
      }

      // Apply distance filter (if coordinates provided)
      if (filters.maxDistance != null &&
          filters.maxDistance! > 0 &&
          filters.userLatitude != null &&
          filters.userLongitude != null) {

        // Note: This is a simplified distance filter
        // For production, consider using PostGIS for better performance
        query = query
            .not('latitude', 'is', null)
            .not('longitude', 'is', null);
      }

      // Apply ordering and pagination
      final orderedQuery = query.order('created_at', ascending: false);
      final paginatedQuery = orderedQuery.range(filters.offset, filters.offset + filters.limit - 1);

      final response = await paginatedQuery;
      final buildings = (response as List)
          .map((json) => Building.fromJson(json))
          .toList();

      // Apply distance filter in memory (for now)
      if (filters.maxDistance != null &&
          filters.maxDistance! > 0 &&
          filters.userLatitude != null &&
          filters.userLongitude != null) {

        buildings.retainWhere((building) {
          if (building.latitude == null || building.longitude == null) {
            return false;
          }

          final distance = _calculateDistance(
            filters.userLatitude!,
            filters.userLongitude!,
            building.latitude!,
            building.longitude!,
          );

          return distance <= filters.maxDistance!;
        });
      }

      return buildings;
    } catch (e) {
      throw Exception('Failed to get filtered buildings: $e');
    }
  }

  // Get filter summary for display
  static Future<BuildingFilterSummary> getFilterSummary() async {
    try {
      final buildingTypes = await getAvailableBuildingTypes();
      final cities = await getAvailableCities();
      final pincodes = await getAvailablePincodes();

      return BuildingFilterSummary(
        totalBuildings: buildingTypes.first.count,
        buildingTypeCount: buildingTypes.length - 1, // Exclude 'Any'
        cityCount: cities.length - 1, // Exclude 'Any'
        pincodeCount: pincodes.length - 1, // Exclude 'Any'
      );
    } catch (e) {
      throw Exception('Failed to get filter summary: $e');
    }
  }

  // Helper method to calculate distance between two coordinates
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degree) => degree * (3.14159265359 / 180.0);
  static double _sin(double x) => dart_math.sin(x);
  static double _cos(double x) => dart_math.cos(x);
  static double _sqrt(double x) => dart_math.sqrt(x);
  static double _atan2(double y, double x) => dart_math.atan2(y, x);
}


// Helper data classes reused from FilterService
class FilterOption {
  final dynamic value;
  final String label;
  final int count;
  final String? category;

  FilterOption({
    required this.value,
    required this.label,
    required this.count,
    this.category,
  });
}

class CityData {
  final String id;
  final String name;
  int count;

  CityData({
    required this.id,
    required this.name,
    required this.count,
  });
}

class BuildingFilterParams {
  final String cityId;
  final String buildingType;
  final String pincode;
  final double? maxDistance;
  final double? userLatitude;
  final double? userLongitude;
  final int limit;
  final int offset;

  BuildingFilterParams({
    this.cityId = 'any',
    this.buildingType = 'any',
    this.pincode = 'any',
    this.maxDistance,
    this.userLatitude,
    this.userLongitude,
    this.limit = 50,
    this.offset = 0,
  });

  BuildingFilterParams copyWith({
    String? cityId,
    String? buildingType,
    String? pincode,
    double? maxDistance,
    double? userLatitude,
    double? userLongitude,
    int? limit,
    int? offset,
  }) {
    return BuildingFilterParams(
      cityId: cityId ?? this.cityId,
      buildingType: buildingType ?? this.buildingType,
      pincode: pincode ?? this.pincode,
      maxDistance: maxDistance ?? this.maxDistance,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

class BuildingFilterSummary {
  final int totalBuildings;
  final int buildingTypeCount;
  final int cityCount;
  final int pincodeCount;

  BuildingFilterSummary({
    required this.totalBuildings,
    required this.buildingTypeCount,
    required this.cityCount,
    required this.pincodeCount,
  });
}