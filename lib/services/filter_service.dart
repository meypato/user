import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'room_service.dart';

class FilterService {
  static final _supabase = Supabase.instance.client;

  // Get available room types with counts for dropdown
  static Future<List<FilterOption>> getAvailableRoomTypes() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('room_type')
          .eq('availability_status', 'available');

      final Map<String, int> typeCounts = {};
      for (final room in response) {
        final roomType = room['room_type'] as String;
        typeCounts[roomType] = (typeCounts[roomType] ?? 0) + 1;
      }

      final List<FilterOption> options = [
        FilterOption(value: 'any', label: 'Any', count: response.length),
      ];

      // Convert enum values to display names with counts
      for (final type in RoomType.values) {
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
      throw Exception('Failed to fetch room types: $e');
    }
  }

  // Get available occupancy ranges with counts
  static Future<List<FilterOption>> getAvailableOccupancyRanges() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('maximum_occupancy')
          .eq('availability_status', 'available');

      final Map<int, int> occupancyCounts = {};
      for (final room in response) {
        final occupancy = room['maximum_occupancy'] as int;
        occupancyCounts[occupancy] = (occupancyCounts[occupancy] ?? 0) + 1;
      }

      final List<FilterOption> options = [
        FilterOption(value: 0, label: 'Any', count: response.length),
      ];

      // Create user-friendly occupancy labels with counts
      final sortedOccupancies = occupancyCounts.keys.toList()..sort();
      for (final occupancy in sortedOccupancies) {
        final count = occupancyCounts[occupancy]!;
        String label;

        if (occupancy == 1) {
          label = '1 Person';
        } else if (occupancy <= 4) {
          label = '$occupancy People';
        } else {
          label = '$occupancy+ People';
        }

        options.add(FilterOption(
          value: occupancy,
          label: label,
          count: count,
        ));
      }

      return options;
    } catch (e) {
      throw Exception('Failed to fetch occupancy ranges: $e');
    }
  }

  // Get available cities in Arunachal Pradesh with room counts
  static Future<List<FilterOption>> getAvailableCities() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            buildings!inner(
              city_id,
              cities(name)
            )
          ''')
          .eq('availability_status', 'available');

      final Map<String, CityData> cityCounts = {};

      for (final room in response) {
        final building = room['buildings'];
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

      // Sort cities by room count (descending)
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

  // Get price range from available rooms
  static Future<PriceRange> getAvailablePriceRange() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('fee')
          .eq('availability_status', 'available')
          .order('fee', ascending: true);

      if (response.isEmpty) {
        return PriceRange(min: 2000, max: 30000);
      }

      final fees = response.map<double>((room) => (room['fee'] as num).toDouble()).toList();

      return PriceRange(
        min: fees.first,
        max: fees.last,
      );
    } catch (e) {
      throw Exception('Failed to fetch price range: $e');
    }
  }

  // Get available amenities with room counts
  static Future<List<FilterOption>> getAvailableAmenities() async {
    try {
      final response = await _supabase
          .from('room_amenities')
          .select('''
            room_id,
            amenities!inner(
              id,
              name,
              category
            ),
            rooms!inner(availability_status)
          ''')
          .eq('rooms.availability_status', 'available');

      final Map<String, AmenityData> amenityCounts = {};

      for (final item in response) {
        final amenity = item['amenities'];
        final amenityId = amenity['id'] as String;
        final amenityName = amenity['name'] as String;
        final amenityCategory = amenity['category'] as String?;

        if (amenityCounts.containsKey(amenityId)) {
          amenityCounts[amenityId]!.count++;
        } else {
          amenityCounts[amenityId] = AmenityData(
            id: amenityId,
            name: amenityName,
            category: amenityCategory,
            count: 1,
          );
        }
      }

      // Group by category and sort by count
      final Map<String, List<FilterOption>> categorizedAmenities = {};

      for (final amenity in amenityCounts.values) {
        final category = amenity.category ?? 'Other';

        if (!categorizedAmenities.containsKey(category)) {
          categorizedAmenities[category] = [];
        }

        categorizedAmenities[category]!.add(FilterOption(
          value: amenity.id,
          label: amenity.name,
          count: amenity.count,
          category: category,
        ));
      }

      // Flatten and sort by count within categories
      final List<FilterOption> options = [];

      for (final category in categorizedAmenities.keys.toList()..sort()) {
        final categoryAmenities = categorizedAmenities[category]!
          ..sort((a, b) => b.count.compareTo(a.count));
        options.addAll(categoryAmenities);
      }

      return options;
    } catch (e) {
      throw Exception('Failed to fetch amenities: $e');
    }
  }

  // Get available building types with counts
  static Future<List<FilterOption>> getAvailableBuildingTypes() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            buildings!inner(building_type)
          ''')
          .eq('availability_status', 'available');

      final Map<String, int> typeCounts = {};

      for (final room in response) {
        final building = room['buildings'];
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

  // Apply filters to get filtered rooms
  static Future<List<Room>> getFilteredRooms(RoomFilterParams filters) async {
    try {
      return await RoomService.getAvailableRooms(
        cityId: filters.cityId != 'any' ? filters.cityId : null,
        roomType: filters.roomType != 'any'
            ? RoomType.fromString(filters.roomType)
            : null,
        maxFee: filters.maxPrice,
        minFee: filters.minPrice,
        limit: filters.limit,
        offset: filters.offset,
      );
    } catch (e) {
      throw Exception('Failed to get filtered rooms: $e');
    }
  }

  // Get filter summary for display
  static Future<FilterSummary> getFilterSummary() async {
    try {
      final roomTypes = await getAvailableRoomTypes();
      final cities = await getAvailableCities();
      final priceRange = await getAvailablePriceRange();
      final occupancyRanges = await getAvailableOccupancyRanges();

      return FilterSummary(
        totalRooms: roomTypes.first.count,
        roomTypeCount: roomTypes.length - 1, // Exclude 'Any'
        cityCount: cities.length - 1, // Exclude 'Any'
        minPrice: priceRange.min,
        maxPrice: priceRange.max,
        maxOccupancy: occupancyRanges.last.value as int,
      );
    } catch (e) {
      throw Exception('Failed to get filter summary: $e');
    }
  }
}

// Helper data classes
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

class PriceRange {
  final double min;
  final double max;

  PriceRange({required this.min, required this.max});
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

class AmenityData {
  final String id;
  final String name;
  final String? category;
  int count;

  AmenityData({
    required this.id,
    required this.name,
    this.category,
    required this.count,
  });
}

class RoomFilterParams {
  final String cityId;
  final String roomType;
  final double? minPrice;
  final double? maxPrice;
  final int? maxOccupancy;
  final List<String> amenityIds;
  final String buildingType;
  final int limit;
  final int offset;

  RoomFilterParams({
    this.cityId = 'any',
    this.roomType = 'any',
    this.minPrice,
    this.maxPrice,
    this.maxOccupancy,
    this.amenityIds = const [],
    this.buildingType = 'any',
    this.limit = 50,
    this.offset = 0,
  });

  RoomFilterParams copyWith({
    String? cityId,
    String? roomType,
    double? minPrice,
    double? maxPrice,
    int? maxOccupancy,
    List<String>? amenityIds,
    String? buildingType,
    int? limit,
    int? offset,
  }) {
    return RoomFilterParams(
      cityId: cityId ?? this.cityId,
      roomType: roomType ?? this.roomType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      maxOccupancy: maxOccupancy ?? this.maxOccupancy,
      amenityIds: amenityIds ?? this.amenityIds,
      buildingType: buildingType ?? this.buildingType,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

class FilterSummary {
  final int totalRooms;
  final int roomTypeCount;
  final int cityCount;
  final double minPrice;
  final double maxPrice;
  final int maxOccupancy;

  FilterSummary({
    required this.totalRooms,
    required this.roomTypeCount,
    required this.cityCount,
    required this.minPrice,
    required this.maxPrice,
    required this.maxOccupancy,
  });
}