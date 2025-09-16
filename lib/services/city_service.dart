import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class CityService {
  static final _supabase = Supabase.instance.client;

  /// Get all cities for a specific state
  static Future<List<City>> getCitiesByState(String stateId) async {
    try {
      final response = await _supabase
          .from('cities')
          .select()
          .eq('state_id', stateId)
          .order('name', ascending: true);

      return response.map<City>((json) => City.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch cities: $e');
    }
  }

  /// Get all cities (for location picker)
  static Future<List<City>> getAllCities() async {
    try {
      final response = await _supabase
          .from('cities')
          .select()
          .order('name', ascending: true);

      return response.map<City>((json) => City.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all cities: $e');
    }
  }

  /// Get a specific city by ID
  static Future<City?> getCityById(String cityId) async {
    try {
      final response = await _supabase
          .from('cities')
          .select()
          .eq('id', cityId)
          .maybeSingle();

      if (response == null) return null;

      return City.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch city: $e');
    }
  }

  /// Search cities by name
  static Future<List<City>> searchCities(String query, {String? stateId}) async {
    try {
      var queryBuilder = _supabase
          .from('cities')
          .select()
          .ilike('name', '%$query%');

      if (stateId != null) {
        queryBuilder = queryBuilder.eq('state_id', stateId);
      }

      final response = await queryBuilder.order('name', ascending: true);

      return response.map<City>((json) => City.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search cities: $e');
    }
  }

  /// Get cities for Arunachal Pradesh specifically
  static Future<List<City>> getArunachalCities() async {
    try {
      // First get Arunachal Pradesh state ID
      final stateResponse = await _supabase
          .from('states')
          .select('id')
          .eq('name', 'Arunachal Pradesh')
          .single();

      final stateId = stateResponse['id'] as String;

      return await getCitiesByState(stateId);
    } catch (e) {
      throw Exception('Failed to fetch Arunachal Pradesh cities: $e');
    }
  }

  /// Get city name by ID (useful for display purposes)
  static Future<String?> getCityName(String cityId) async {
    try {
      final city = await getCityById(cityId);
      return city?.name;
    } catch (e) {
      return null;
    }
  }
}