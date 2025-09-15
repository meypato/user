import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class BuildingService {
  static final _client = Supabase.instance.client;

  /// Get available buildings with optional filtering
  static Future<List<Building>> getAvailableBuildings({
    int? limit,
    BuildingType? buildingType,
  }) async {
    try {
      var baseQuery = _client
          .from('buildings')
          .select('*')
          .eq('is_active', true);

      // Apply building type filter
      if (buildingType != null) {
        baseQuery = baseQuery.eq('building_type', buildingType.name);
      }

      var finalQuery = baseQuery.order('created_at', ascending: false);

      // Apply limit
      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;

      return (response as List)
          .map((json) => Building.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load buildings: $e');
    }
  }

  /// Get building by ID
  static Future<Building?> getBuildingById(String buildingId) async {
    try {
      final response = await _client
          .from('buildings')
          .select('*')
          .eq('id', buildingId)
          .single();

      return Building.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load building details: $e');
    }
  }

  /// Search buildings by name or location
  static Future<List<Building>> searchBuildings(String searchQuery) async {
    try {
      final response = await _client
          .from('buildings')
          .select('*')
          .eq('is_active', true)
          .or('name.ilike.%$searchQuery%,address_line1.ilike.%$searchQuery%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Building.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search buildings: $e');
    }
  }

  /// Get buildings by city
  static Future<List<Building>> getBuildingsByCity(String cityId) async {
    try {
      final response = await _client
          .from('buildings')
          .select('*')
          .eq('is_active', true)
          .eq('city_id', cityId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Building.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load buildings by city: $e');
    }
  }

  /// Get buildings by owner
  static Future<List<Building>> getBuildingsByOwner(String ownerId) async {
    try {
      final response = await _client
          .from('buildings')
          .select('*')
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Building.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load owner buildings: $e');
    }
  }

  /// Create a new building (for owners/agents)
  static Future<Building> createBuilding(Building building) async {
    try {
      final response = await _client
          .from('buildings')
          .insert(building.toJson())
          .select()
          .single();

      return Building.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create building: $e');
    }
  }

  /// Update building information
  static Future<Building> updateBuilding(Building building) async {
    try {
      final response = await _client
          .from('buildings')
          .update(building.toJson())
          .eq('id', building.id)
          .select()
          .single();

      return Building.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update building: $e');
    }
  }

  /// Delete building (soft delete by setting is_active to false)
  static Future<void> deleteBuilding(String buildingId) async {
    try {
      await _client
          .from('buildings')
          .update({'is_active': false})
          .eq('id', buildingId);
    } catch (e) {
      throw Exception('Failed to delete building: $e');
    }
  }

  /// Get rooms for a specific building
  static Future<List<Room>> getRoomsByBuildingId(String buildingId) async {
    try {
      final response = await _client
          .from('rooms')
          .select('*')
          .eq('building_id', buildingId)
          .order('room_number', ascending: true);

      return (response as List)
          .map((json) => Room.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load building rooms: $e');
    }
  }
}