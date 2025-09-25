import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class FeaturedService {
  static final _supabase = Supabase.instance.client;

  // Get featured rooms with priority sorting
  static Future<List<Room>> getFeaturedRooms({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            *,
            buildings!inner(
              id,
              name,
              address_line1,
              address_line2,
              state_id,
              city_id,
              building_type,
              is_active,
              cities(name)
            )
          ''')
          .eq('availability_status', 'available')
          .eq('is_featured', true)
          .order('featured_priority', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      final filteredResults = response.where((roomJson) {
        final building = roomJson['buildings'];
        return building['is_active'] == true;
      }).toList();

      return filteredResults.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured rooms: $e');
    }
  }

  // Get popular rooms
  static Future<List<Room>> getPopularRooms({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            *,
            buildings!inner(
              id,
              name,
              address_line1,
              address_line2,
              state_id,
              city_id,
              building_type,
              is_active,
              cities(name)
            )
          ''')
          .eq('availability_status', 'available')
          .eq('is_popular', true)
          .order('created_at', ascending: false)
          .limit(limit);

      final filteredResults = response.where((roomJson) {
        final building = roomJson['buildings'];
        return building['is_active'] == true;
      }).toList();

      return filteredResults.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular rooms: $e');
    }
  }

  // Get featured buildings with priority sorting
  static Future<List<Building>> getFeaturedBuildings({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('buildings')
          .select('''
            *,
            cities(name)
          ''')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('featured_priority', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Building>((json) => Building.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured buildings: $e');
    }
  }

  // Get popular buildings
  static Future<List<Building>> getPopularBuildings({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('buildings')
          .select('''
            *,
            cities(name)
          ''')
          .eq('is_active', true)
          .eq('is_popular', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<Building>((json) => Building.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch popular buildings: $e');
    }
  }

  // Get rooms with featured priority (featured first, then popular, then regular)
  static Future<List<Room>> getRoomsWithFeaturedPriority({
    int limit = 20,
    int offset = 0,
    String? cityId,
    RoomType? roomType,
    double? maxFee,
    bool? checkProfileComplete,
  }) async {
    try {
      // Return empty list if profile is incomplete (excluding documents)
      if (checkProfileComplete == false) {
        return [];
      }

      var query = _supabase
          .from('rooms')
          .select('''
            *,
            buildings!inner(
              id,
              name,
              address_line1,
              address_line2,
              state_id,
              city_id,
              building_type,
              is_active,
              cities(name)
            )
          ''')
          .eq('availability_status', 'available')
          .order('is_featured', ascending: false)
          .order('featured_priority', ascending: false)
          .order('is_popular', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await query;

      var filteredResults = response.where((roomJson) {
        final building = roomJson['buildings'];

        if (building['is_active'] != true) return false;
        if (cityId != null && building['city_id'] != cityId) return false;
        if (roomType != null && roomJson['room_type'] != roomType.name) return false;

        if (maxFee != null) {
          final fee = (roomJson['fee'] as num).toDouble();
          if (fee > maxFee) return false;
        }

        return true;
      }).toList();

      return filteredResults.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms with featured priority: $e');
    }
  }

  // Get buildings with featured priority (featured first, then popular, then regular)
  static Future<List<Building>> getBuildingsWithFeaturedPriority({
    int limit = 20,
    int offset = 0,
    String? cityId,
    BuildingType? buildingType,
    bool? checkProfileComplete,
  }) async {
    try {
      // Return empty list if profile is incomplete (excluding documents)
      if (checkProfileComplete == false) {
        return [];
      }

      var query = _supabase
          .from('buildings')
          .select('''
            *,
            cities(name)
          ''')
          .eq('is_active', true)
          .order('is_featured', ascending: false)
          .order('featured_priority', ascending: false)
          .order('is_popular', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await query;

      var filteredResults = response.where((buildingJson) {
        if (cityId != null && buildingJson['city_id'] != cityId) return false;
        if (buildingType != null && buildingJson['building_type'] != buildingType.name) return false;
        return true;
      }).toList();

      return filteredResults.map<Building>((json) => Building.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch buildings with featured priority: $e');
    }
  }

  // Update room featured status (for admin/owner use)
  static Future<Room> updateRoomFeaturedStatus({
    required String roomId,
    required bool isFeatured,
    required bool isPopular,
    int featuredPriority = 0,
  }) async {
    try {
      final response = await _supabase
          .from('rooms')
          .update({
            'is_featured': isFeatured,
            'is_popular': isPopular,
            'featured_priority': featuredPriority,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', roomId)
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update room featured status: $e');
    }
  }

  // Update building featured status (for admin/owner use)
  static Future<Building> updateBuildingFeaturedStatus({
    required String buildingId,
    required bool isFeatured,
    required bool isPopular,
    int featuredPriority = 0,
  }) async {
    try {
      final response = await _supabase
          .from('buildings')
          .update({
            'is_featured': isFeatured,
            'is_popular': isPopular,
            'featured_priority': featuredPriority,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', buildingId)
          .select()
          .single();

      return Building.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update building featured status: $e');
    }
  }

  // Get featured listings count for analytics
  static Future<Map<String, int>> getFeaturedCounts() async {
    try {
      final featuredRoomsCount = await _supabase
          .from('rooms')
          .select('id')
          .eq('is_featured', true)
          .eq('availability_status', 'available')
          .count(CountOption.exact);

      final popularRoomsCount = await _supabase
          .from('rooms')
          .select('id')
          .eq('is_popular', true)
          .eq('availability_status', 'available')
          .count(CountOption.exact);

      final featuredBuildingsCount = await _supabase
          .from('buildings')
          .select('id')
          .eq('is_featured', true)
          .eq('is_active', true)
          .count(CountOption.exact);

      final popularBuildingsCount = await _supabase
          .from('buildings')
          .select('id')
          .eq('is_popular', true)
          .eq('is_active', true)
          .count(CountOption.exact);

      return {
        'featured_rooms': featuredRoomsCount.count,
        'popular_rooms': popularRoomsCount.count,
        'featured_buildings': featuredBuildingsCount.count,
        'popular_buildings': popularBuildingsCount.count,
      };
    } catch (e) {
      throw Exception('Failed to fetch featured counts: $e');
    }
  }

  // Batch update multiple rooms featured status
  static Future<List<Room>> batchUpdateRoomsFeaturedStatus(
    List<String> roomIds,
    bool isFeatured,
    bool isPopular,
    int featuredPriority,
  ) async {
    try {
      final response = await _supabase
          .from('rooms')
          .update({
            'is_featured': isFeatured,
            'is_popular': isPopular,
            'featured_priority': featuredPriority,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', roomIds)
          .select();

      return response.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to batch update rooms featured status: $e');
    }
  }

  // Batch update multiple buildings featured status
  static Future<List<Building>> batchUpdateBuildingsFeaturedStatus(
    List<String> buildingIds,
    bool isFeatured,
    bool isPopular,
    int featuredPriority,
  ) async {
    try {
      final response = await _supabase
          .from('buildings')
          .update({
            'is_featured': isFeatured,
            'is_popular': isPopular,
            'featured_priority': featuredPriority,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .inFilter('id', buildingIds)
          .select();

      return response.map<Building>((json) => Building.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to batch update buildings featured status: $e');
    }
  }
}