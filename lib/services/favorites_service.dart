import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/favorite.dart';

class FavoritesService {
  static final _supabase = Supabase.instance.client;

  // Room Favorites
  static Future<List<UserFavoriteRoom>> getUserFavoriteRooms(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorite_rooms')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserFavoriteRoom.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite rooms: $e');
    }
  }

  static Future<bool> isRoomFavorited(String userId, String roomId) async {
    try {
      final response = await _supabase
          .from('user_favorite_rooms')
          .select('room_id')
          .eq('user_id', userId)
          .eq('room_id', roomId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check room favorite status: $e');
    }
  }

  static Future<void> addRoomToFavorites(String userId, String roomId) async {
    try {
      await _supabase
          .from('user_favorite_rooms')
          .insert({
            'user_id': userId,
            'room_id': roomId,
          });
    } catch (e) {
      throw Exception('Failed to add room to favorites: $e');
    }
  }

  static Future<void> removeRoomFromFavorites(String userId, String roomId) async {
    try {
      await _supabase
          .from('user_favorite_rooms')
          .delete()
          .eq('user_id', userId)
          .eq('room_id', roomId);
    } catch (e) {
      throw Exception('Failed to remove room from favorites: $e');
    }
  }

  // Building Favorites
  static Future<List<UserFavoriteBuilding>> getUserFavoriteBuildings(String userId) async {
    try {
      final response = await _supabase
          .from('user_favorite_buildings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserFavoriteBuilding.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite buildings: $e');
    }
  }

  static Future<bool> isBuildingFavorited(String userId, String buildingId) async {
    try {
      final response = await _supabase
          .from('user_favorite_buildings')
          .select('building_id')
          .eq('user_id', userId)
          .eq('building_id', buildingId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      throw Exception('Failed to check building favorite status: $e');
    }
  }

  static Future<void> addBuildingToFavorites(String userId, String buildingId) async {
    try {
      await _supabase
          .from('user_favorite_buildings')
          .insert({
            'user_id': userId,
            'building_id': buildingId,
          });
    } catch (e) {
      throw Exception('Failed to add building to favorites: $e');
    }
  }

  static Future<void> removeBuildingFromFavorites(String userId, String buildingId) async {
    try {
      await _supabase
          .from('user_favorite_buildings')
          .delete()
          .eq('user_id', userId)
          .eq('building_id', buildingId);
    } catch (e) {
      throw Exception('Failed to remove building from favorites: $e');
    }
  }

  // Utility Methods
  static Future<Set<String>> getUserFavoriteRoomIds(String userId) async {
    try {
      final favorites = await getUserFavoriteRooms(userId);
      return favorites.map((fav) => fav.roomId).toSet();
    } catch (e) {
      throw Exception('Failed to fetch favorite room IDs: $e');
    }
  }

  static Future<Set<String>> getUserFavoriteBuildingIds(String userId) async {
    try {
      final favorites = await getUserFavoriteBuildings(userId);
      return favorites.map((fav) => fav.buildingId).toSet();
    } catch (e) {
      throw Exception('Failed to fetch favorite building IDs: $e');
    }
  }

  // Batch operations for efficiency
  static Future<Map<String, bool>> checkMultipleRoomsFavorited(
    String userId,
    List<String> roomIds
  ) async {
    try {
      final response = await _supabase
          .from('user_favorite_rooms')
          .select('room_id')
          .eq('user_id', userId)
          .inFilter('room_id', roomIds);

      final favoritedIds = (response as List)
          .map((item) => item['room_id'] as String)
          .toSet();

      return Map.fromEntries(
        roomIds.map((id) => MapEntry(id, favoritedIds.contains(id)))
      );
    } catch (e) {
      throw Exception('Failed to check multiple rooms favorite status: $e');
    }
  }

  static Future<Map<String, bool>> checkMultipleBuildingsFavorited(
    String userId,
    List<String> buildingIds
  ) async {
    try {
      final response = await _supabase
          .from('user_favorite_buildings')
          .select('building_id')
          .eq('user_id', userId)
          .inFilter('building_id', buildingIds);

      final favoritedIds = (response as List)
          .map((item) => item['building_id'] as String)
          .toSet();

      return Map.fromEntries(
        buildingIds.map((id) => MapEntry(id, favoritedIds.contains(id)))
      );
    } catch (e) {
      throw Exception('Failed to check multiple buildings favorite status: $e');
    }
  }
}