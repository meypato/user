import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  Set<String> _favoriteRoomIds = {};
  Set<String> _favoriteBuildingIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Set<String> get favoriteRoomIds => _favoriteRoomIds;
  Set<String> get favoriteBuildingIds => _favoriteBuildingIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Check if specific items are favorited
  bool isRoomFavorited(String roomId) => _favoriteRoomIds.contains(roomId);
  bool isBuildingFavorited(String buildingId) => _favoriteBuildingIds.contains(buildingId);

  // Get current user ID
  String? get _currentUserId {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.id;
  }

  // Load user's favorites from database
  Future<void> loadFavorites() async {
    final userId = _currentUserId;
    if (userId == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Load both room and building favorites in parallel
      final results = await Future.wait([
        FavoritesService.getUserFavoriteRoomIds(userId),
        FavoritesService.getUserFavoriteBuildingIds(userId),
      ]);

      _favoriteRoomIds = results[0];
      _favoriteBuildingIds = results[1];

      notifyListeners();
    } catch (e) {
      _setError('Failed to load favorites: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Toggle room favorite
  Future<void> toggleRoomFavorite(String roomId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      if (_favoriteRoomIds.contains(roomId)) {
        // Remove from favorites
        await FavoritesService.removeRoomFromFavorites(userId, roomId);
        _favoriteRoomIds.remove(roomId);
      } else {
        // Add to favorites
        await FavoritesService.addRoomToFavorites(userId, roomId);
        _favoriteRoomIds.add(roomId);
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to update room favorite: $e');
    }
  }

  // Toggle building favorite
  Future<void> toggleBuildingFavorite(String buildingId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      if (_favoriteBuildingIds.contains(buildingId)) {
        // Remove from favorites
        await FavoritesService.removeBuildingFromFavorites(userId, buildingId);
        _favoriteBuildingIds.remove(buildingId);
      } else {
        // Add to favorites
        await FavoritesService.addBuildingToFavorites(userId, buildingId);
        _favoriteBuildingIds.add(buildingId);
      }
      notifyListeners();
    } catch (e) {
      _setError('Failed to update building favorite: $e');
    }
  }

  // Add room to favorites
  Future<void> addRoomToFavorites(String roomId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await FavoritesService.addRoomToFavorites(userId, roomId);
      _favoriteRoomIds.add(roomId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add room to favorites: $e');
    }
  }

  // Remove room from favorites
  Future<void> removeRoomFromFavorites(String roomId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await FavoritesService.removeRoomFromFavorites(userId, roomId);
      _favoriteRoomIds.remove(roomId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove room from favorites: $e');
    }
  }

  // Add building to favorites
  Future<void> addBuildingToFavorites(String buildingId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await FavoritesService.addBuildingToFavorites(userId, buildingId);
      _favoriteBuildingIds.add(buildingId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to add building to favorites: $e');
    }
  }

  // Remove building from favorites
  Future<void> removeBuildingFromFavorites(String buildingId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      await FavoritesService.removeBuildingFromFavorites(userId, buildingId);
      _favoriteBuildingIds.remove(buildingId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove building from favorites: $e');
    }
  }

  // Batch check favorites for multiple items (for performance in lists)
  Future<void> checkFavoritesStatus({
    List<String>? roomIds,
    List<String>? buildingIds,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    try {
      final futures = <Future>[];

      if (roomIds != null && roomIds.isNotEmpty) {
        futures.add(
          FavoritesService.checkMultipleRoomsFavorited(userId, roomIds)
              .then((results) {
            for (final entry in results.entries) {
              if (entry.value) {
                _favoriteRoomIds.add(entry.key);
              } else {
                _favoriteRoomIds.remove(entry.key);
              }
            }
          })
        );
      }

      if (buildingIds != null && buildingIds.isNotEmpty) {
        futures.add(
          FavoritesService.checkMultipleBuildingsFavorited(userId, buildingIds)
              .then((results) {
            for (final entry in results.entries) {
              if (entry.value) {
                _favoriteBuildingIds.add(entry.key);
              } else {
                _favoriteBuildingIds.remove(entry.key);
              }
            }
          })
        );
      }

      await Future.wait(futures);
      notifyListeners();
    } catch (e) {
      _setError('Failed to check favorites status: $e');
    }
  }

  // Clear all favorites (for logout)
  void clearFavorites() {
    _favoriteRoomIds.clear();
    _favoriteBuildingIds.clear();
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Get counts
  int get favoriteRoomsCount => _favoriteRoomIds.length;
  int get favoriteBuildingsCount => _favoriteBuildingIds.length;
  int get totalFavoritesCount => favoriteRoomsCount + favoriteBuildingsCount;
}