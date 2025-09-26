import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colour.dart';
import '../../widgets/bottom_navigation.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/rent_item_card.dart';
import '../../widgets/building_item_card.dart';
import '../../widgets/navigation_wrapper.dart';
import '../../providers/favorites_provider.dart';
import '../../services/room_service.dart';
import '../../services/building_service.dart';
import '../../models/models.dart' hide State;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Room> _favoriteRooms = [];
  List<Building> _favoriteBuildings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final favoritesProvider = context.read<FavoritesProvider>();

      // Get favorite IDs
      final favoriteRoomIds = favoritesProvider.favoriteRoomIds.toList();
      final favoriteBuildingIds = favoritesProvider.favoriteBuildingIds.toList();

      // Fetch actual room and building data
      final roomsFuture = RoomService.getRoomsByIds(favoriteRoomIds);
      final buildingsFuture = BuildingService.getBuildingsByIds(favoriteBuildingIds);

      final results = await Future.wait([roomsFuture, buildingsFuture]);

      if (mounted) {
        setState(() {
          _favoriteRooms = results[0] as List<Room>;
          _favoriteBuildings = results[1] as List<Building>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return NavigationWrapper(
      child: Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        elevation: 0,
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
        bottom: _buildTabBar(isDark),
      ),
      body: _isLoading ? _buildLoadingState() : _buildTabBarView(),
      extendBody: true,
      bottomNavigationBar: const CustomBottomNavigation(
        currentIndex: 3, // Favorites tab index
      ),
      ),
    );
  }

  TabBar _buildTabBar(bool isDark) {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primaryBlue,
      labelColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      tabs: [
        Tab(
          text: 'Rooms (${_favoriteRooms.length})',
          icon: const Icon(Icons.bed, size: 20),
        ),
        Tab(
          text: 'Buildings (${_favoriteBuildings.length})',
          icon: const Icon(Icons.apartment, size: 20),
        ),
      ],
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildRoomsTab(),
        _buildBuildingsTab(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your favorites...'),
        ],
      ),
    );
  }

  Widget _buildRoomsTab() {
    if (_favoriteRooms.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bed,
        title: 'No Favorite Rooms',
        message: 'Start exploring rooms and tap the heart icon to add them to your favorites.',
        actionText: 'Browse Rooms',
        onAction: () => Navigator.pushNamed(context, '/rent'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: _favoriteRooms.length,
        itemBuilder: (context, index) {
          final room = _favoriteRooms[index];
          return RentItemCard(
            room: room,
            isFirst: index == 0,
          );
        },
      ),
    );
  }

  Widget _buildBuildingsTab() {
    if (_favoriteBuildings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.apartment,
        title: 'No Favorite Buildings',
        message: 'Start exploring buildings and tap the heart icon to add them to your favorites.',
        actionText: 'Browse Buildings',
        onAction: () => Navigator.pushNamed(context, '/building'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _favoriteBuildings.length,
          itemBuilder: (context, index) {
            final building = _favoriteBuildings[index];
            return BuildingItemCard(building: building);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                actionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}