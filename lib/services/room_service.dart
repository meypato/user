import 'dart:io';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class RoomService {
  static final _supabase = Supabase.instance.client;

  // Get all available rooms with optional filtering
  static Future<List<Room>> getAvailableRooms({
    String? stateId,
    String? cityId,
    RoomType? roomType,
    double? maxFee,
    double? minFee,
    String? buildingId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
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
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final response = await query;
      
      // Filter results based on criteria
      var filteredResults = response.where((roomJson) {
        final building = roomJson['buildings'];
        
        // Check if building is active
        if (building['is_active'] != true) return false;
        
        // Apply location filters
        if (stateId != null && building['state_id'] != stateId) return false;
        if (cityId != null && building['city_id'] != cityId) return false;
        
        // Apply room type filter
        if (roomType != null && roomJson['room_type'] != roomType.name) return false;
        
        // Apply fee filters
        final fee = (roomJson['fee'] as num).toDouble();
        if (maxFee != null && fee > maxFee) return false;
        if (minFee != null && fee < minFee) return false;
        
        // Apply building filter
        if (buildingId != null && roomJson['building_id'] != buildingId) return false;
        
        return true;
      }).toList();
      
      return filteredResults.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch available rooms: $e');
    }
  }

  // Get rooms by building ID
  static Future<List<Room>> getRoomsByBuilding(String buildingId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('building_id', buildingId)
          .order('room_number', ascending: true);

      return response.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms for building: $e');
    }
  }

  // Get room by ID with building details
  static Future<Room?> getRoomById(String roomId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            *,
            buildings(
              id,
              name,
              address_line1,
              address_line2,
              state_id,
              city_id,
              building_type,
              contact_person_name,
              contact_person_phone,
              photos,
              rules_file_url,
              cities(name)
            )
          ''')
          .eq('id', roomId)
          .maybeSingle();

      if (response == null) return null;

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch room: $e');
    }
  }

  // Get room details with building and city info (using working nested query pattern)
  static Future<RoomDetail?> getRoomDetail(String roomId) async {
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
              contact_person_name,
              contact_person_phone,
              photos,
              latitude,
              longitude,
              google_maps_link,
              cities(name)
            )
          ''')
          .eq('id', roomId)
          .maybeSingle();

      if (response == null) return null;

      return RoomDetail.fromNestedJson(response);
    } catch (e) {
      throw Exception('Failed to fetch room details: $e');
    }
  }

  // Search rooms with text query
  static Future<List<Room>> searchRooms({
    required String query,
    String? stateId,
    String? cityId,
    int limit = 20,
    int offset = 0,
  }) async {
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
          .or('name.ilike.%$query%,description.ilike.%$query%,buildings.name.ilike.%$query%,buildings.address_line1.ilike.%$query%')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Filter by location if specified
      var filteredResults = response.where((roomJson) {
        final building = roomJson['buildings'];
        
        if (building['is_active'] != true) return false;
        if (stateId != null && building['state_id'] != stateId) return false;
        if (cityId != null && building['city_id'] != cityId) return false;
        
        return true;
      }).toList();
      
      return filteredResults.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search rooms: $e');
    }
  }

  // Get rooms with APST/profession filtering for cultural compatibility
  static Future<List<Room>> getRoomsWithCompatibilityFilter({
    required String userId,
    String? stateId,
    String? cityId,
    RoomType? roomType,
    double? maxFee,
    double? minFee,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // First get user's profile to check tribe and profession
      final userProfile = await _supabase
          .from('profiles')
          .select('tribe_id, profession_id')
          .eq('id', userId)
          .single();

      final userTribeId = userProfile['tribe_id'] as String?;
      final userProfessionId = userProfile['profession_id'] as String?;

      // Get rooms and check for exclusions
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
              building_tribe_exceptions(tribe_id),
              building_profession_exceptions(profession_id),
              cities(name)
            )
          ''')
          .eq('availability_status', 'available')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Filter results based on all criteria including exclusions
      var filteredResults = response.where((roomJson) {
        final building = roomJson['buildings'];
        
        // Check if building is active
        if (building['is_active'] != true) return false;
        
        // Apply location filters
        if (stateId != null && building['state_id'] != stateId) return false;
        if (cityId != null && building['city_id'] != cityId) return false;
        
        // Apply room type filter
        if (roomType != null && roomJson['room_type'] != roomType.name) return false;
        
        // Apply fee filters
        final fee = (roomJson['fee'] as num).toDouble();
        if (maxFee != null && fee > maxFee) return false;
        if (minFee != null && fee < minFee) return false;
        
        // Check tribe exclusions
        if (userTribeId != null && building['building_tribe_exceptions'] != null) {
          final tribeExceptions = building['building_tribe_exceptions'] as List;
          if (tribeExceptions.any((exception) => exception['tribe_id'] == userTribeId)) {
            return false; // User's tribe is excluded
          }
        }
        
        // Check profession exclusions
        if (userProfessionId != null && building['building_profession_exceptions'] != null) {
          final professionExceptions = building['building_profession_exceptions'] as List;
          if (professionExceptions.any((exception) => exception['profession_id'] == userProfessionId)) {
            return false; // User's profession is excluded
          }
        }
        
        return true; // Room is accessible
      }).toList();
      
      return filteredResults.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch compatible rooms: $e');
    }
  }

  // Get room amenities
  static Future<List<Amenity>> getRoomAmenities(String roomId) async {
    try {
      final response = await _supabase
          .from('room_amenities')
          .select('''
            amenities(
              id,
              name,
              category
            )
          ''')
          .eq('room_id', roomId);

      return response
          .map<Amenity>((json) => Amenity.fromJson(json['amenities']))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch room amenities: $e');
    }
  }

  // Get nearby rooms using location
  static Future<List<Room>> getNearbyRooms({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
  }) async {
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
              latitude,
              longitude,
              is_active,
              cities(name)
            )
          ''')
          .eq('availability_status', 'available')
          .limit(limit);

      // Filter by distance and active buildings
      final filteredRooms = response.where((roomJson) {
        final building = roomJson['buildings'];
        
        if (building['is_active'] != true) return false;
        
        final buildingLat = building['latitude'] as double?;
        final buildingLng = building['longitude'] as double?;
        
        if (buildingLat == null || buildingLng == null) return false;
        
        // Calculate distance
        final distance = _calculateDistance(latitude, longitude, buildingLat, buildingLng);
        return distance <= radiusKm;
      }).toList();
      
      return filteredRooms.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch nearby rooms: $e');
    }
  }

  // Upload room photos (for property owners/agents)
  static Future<List<String>> uploadRoomPhotos(String roomId, List<File> photos) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final uploadedUrls = <String>[];
      
      for (int i = 0; i < photos.length; i++) {
        final file = photos[i];
        final fileName = 'room_${roomId}_photo_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        await _supabase.storage
            .from('room-photos')
            .uploadBinary('$roomId/$fileName', await file.readAsBytes());

        final publicUrl = _supabase.storage
            .from('room-photos')
            .getPublicUrl('$roomId/$fileName');
            
        uploadedUrls.add(publicUrl);
      }

      // Update room with new photos
      final existingRoom = await getRoomById(roomId);
      if (existingRoom != null) {
        final updatedPhotos = [...existingRoom.photos, ...uploadedUrls];
        await _supabase
            .from('rooms')
            .update({'photos': updatedPhotos})
            .eq('id', roomId);
      }

      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload room photos: $e');
    }
  }

  // Update room availability status
  static Future<Room> updateRoomAvailability(String roomId, RoomAvailability status) async {
    try {
      final response = await _supabase
          .from('rooms')
          .update({
            'availability_status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', roomId)
          .select()
          .single();

      return Room.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update room availability: $e');
    }
  }

  // Get room statistics for analytics
  static Future<Map<String, dynamic>> getRoomStats() async {
    try {
      // Get total rooms count
      final totalRooms = await _supabase
          .from('rooms')
          .select('id')
          .count(CountOption.exact);
          
      // Get available rooms count
      final availableRooms = await _supabase
          .from('rooms')
          .select('id')
          .eq('availability_status', 'available')
          .count(CountOption.exact);
          
      // Get occupied rooms count
      final occupiedRooms = await _supabase
          .from('rooms')
          .select('id')
          .eq('availability_status', 'occupied')
          .count(CountOption.exact);

      final totalCount = totalRooms.count;
      final availableCount = availableRooms.count;
      final occupiedCount = occupiedRooms.count;

      return {
        'total_rooms': totalCount,
        'available_rooms': availableCount,
        'occupied_rooms': occupiedCount,
        'occupancy_rate': totalCount > 0 
            ? (occupiedCount / totalCount * 100).toStringAsFixed(1)
            : '0.0',
      };
    } catch (e) {
      throw Exception('Failed to fetch room statistics: $e');
    }
  }

  // Helper method to calculate distance between two coordinates
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * 
        sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get room pricing statistics for a specific area
  static Future<Map<String, dynamic>> getRoomPricingStats({
    String? stateId,
    String? cityId,
    RoomType? roomType,
  }) async {
    try {
      String selectQuery = 'fee';
      
      if (stateId != null || cityId != null) {
        selectQuery = 'fee, buildings!inner(state_id, city_id)';
      }
      
      var query = _supabase
          .from('rooms')
          .select(selectQuery)
          .eq('availability_status', 'available');
      
      if (roomType != null) {
        query = query.eq('room_type', roomType.name);
      }

      final response = await query;
      
      // Filter by location if needed
      var filteredRooms = response;
      if (stateId != null || cityId != null) {
        filteredRooms = response.where((room) {
          final building = room['buildings'];
          if (stateId != null && building['state_id'] != stateId) return false;
          if (cityId != null && building['city_id'] != cityId) return false;
          return true;
        }).toList();
      }
      
      if (filteredRooms.isEmpty) {
        return {
          'min_fee': 0,
          'max_fee': 0,
          'avg_fee': 0,
          'median_fee': 0,
          'total_rooms': 0,
        };
      }

      final fees = filteredRooms.map<double>((room) => (room['fee'] as num).toDouble()).toList();
      fees.sort();

      return {
        'min_fee': fees.first,
        'max_fee': fees.last,
        'avg_fee': fees.reduce((a, b) => a + b) / fees.length,
        'median_fee': fees.length % 2 == 0 
            ? (fees[fees.length ~/ 2 - 1] + fees[fees.length ~/ 2]) / 2
            : fees[fees.length ~/ 2],
        'total_rooms': fees.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch room pricing statistics: $e');
    }
  }

  // Get rooms by availability status
  static Future<List<Room>> getRoomsByStatus(RoomAvailability status) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('''
            *,
            buildings(
              id,
              name,
              address_line1,
              building_type
            )
          ''')
          .eq('availability_status', status.name)
          .order('updated_at', ascending: false);

      return response.map<Room>((json) => Room.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rooms by status: $e');
    }
  }

  // Get available room types with counts
  static Future<Map<String, int>> getRoomTypeCounts() async {
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

      return typeCounts;
    } catch (e) {
      throw Exception('Failed to fetch room type counts: $e');
    }
  }

  // Get distinct room types for dropdown
  static Future<List<String>> getAvailableRoomTypes() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('room_type')
          .eq('availability_status', 'available')
          .order('room_type', ascending: true);

      final Set<String> uniqueTypes = {};
      for (final room in response) {
        final roomTypeString = room['room_type'] as String;
        // Convert to enum to get proper display name
        try {
          final roomType = RoomType.fromString(roomTypeString);
          uniqueTypes.add(roomType.displayName);
        } catch (e) {
          // Fallback to capitalized string if enum conversion fails
          final displayType = roomTypeString[0].toUpperCase() + roomTypeString.substring(1);
          uniqueTypes.add(displayType);
        }
      }

      final List<String> sortedTypes = ['Any', ...uniqueTypes];
      return sortedTypes;
    } catch (e) {
      throw Exception('Failed to fetch available room types: $e');
    }
  }

  // Get distinct occupancy ranges for dropdown
  static Future<List<String>> getAvailableOccupancyRanges() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('maximum_occupancy')
          .eq('availability_status', 'available')
          .order('maximum_occupancy', ascending: true);

      final Set<int> uniqueOccupancies = {};
      for (final room in response) {
        final occupancy = room['maximum_occupancy'] as int;
        uniqueOccupancies.add(occupancy);
      }

      // Create user-friendly occupancy labels
      final List<String> occupancyRanges = ['Any'];
      for (final occupancy in uniqueOccupancies.toList()..sort()) {
        if (occupancy == 1) {
          occupancyRanges.add('1 Person');
        } else if (occupancy <= 4) {
          occupancyRanges.add('$occupancy People');
        } else {
          occupancyRanges.add('$occupancy+ People');
        }
      }

      // Remove duplicates and return
      return occupancyRanges.toSet().toList();
    } catch (e) {
      throw Exception('Failed to fetch available occupancy ranges: $e');
    }
  }

  // Get price range from available rooms
  static Future<Map<String, double>> getAvailablePriceRange() async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('fee')
          .eq('availability_status', 'available')
          .order('fee', ascending: true);

      if (response.isEmpty) {
        return {
          'min': 2000.0,
          'max': 30000.0,
        };
      }

      final fees = response.map<double>((room) => (room['fee'] as num).toDouble()).toList();

      return {
        'min': fees.first,
        'max': fees.last,
      };
    } catch (e) {
      throw Exception('Failed to fetch price range: $e');
    }
  }

  // Get rooms by their IDs (for favorites)
  static Future<List<Room>> getRoomsByIds(List<String> roomIds) async {
    if (roomIds.isEmpty) return [];

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
              cities(name)
            )
          ''')
          .inFilter('id', roomIds)
          .order('created_at', ascending: false);

      return response.map<Room>((roomJson) => Room.fromJson(roomJson)).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite rooms: $e');
    }
  }
}