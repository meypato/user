import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

class FavoriteIconButton extends StatelessWidget {
  final String? roomId;
  final String? buildingId;
  final double size;
  final Color? favoriteColor;
  final Color? unfavoriteColor;
  final bool showBackground;
  final VoidCallback? onToggle;

  const FavoriteIconButton({
    super.key,
    this.roomId,
    this.buildingId,
    this.size = 24,
    this.favoriteColor,
    this.unfavoriteColor,
    this.showBackground = true,
    this.onToggle,
  }) : assert(roomId != null || buildingId != null, 'Either roomId or buildingId must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        // Determine if item is favorited
        final bool isFavorited = roomId != null
            ? favoritesProvider.isRoomFavorited(roomId!)
            : favoritesProvider.isBuildingFavorited(buildingId!);

        // Color logic
        final Color iconColor = isFavorited
            ? (favoriteColor ?? Colors.red)
            : (unfavoriteColor ?? (isDark ? Colors.white70 : Colors.grey.shade600));

        final Color backgroundColor = isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.9);

        return GestureDetector(
          onTap: () async {
            // Call custom callback if provided
            if (onToggle != null) {
              onToggle!();
              return;
            }

            // Default toggle behavior
            try {
              if (roomId != null) {
                await favoritesProvider.toggleRoomFavorite(roomId!);
              } else if (buildingId != null) {
                await favoritesProvider.toggleBuildingFavorite(buildingId!);
              }
            } catch (e) {
              // Show error snackbar
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update favorite: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: size + 16,
              height: size + 16,
              decoration: showBackground
                  ? BoxDecoration(
                      color: backgroundColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                  : null,
              child: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                size: size,
                color: iconColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Specialized variants for common use cases
class CardFavoriteIcon extends StatelessWidget {
  final String? roomId;
  final String? buildingId;
  final VoidCallback? onToggle;

  const CardFavoriteIcon({
    super.key,
    this.roomId,
    this.buildingId,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FavoriteIconButton(
      roomId: roomId,
      buildingId: buildingId,
      size: 20,
      favoriteColor: Colors.red,
      showBackground: true,
      onToggle: onToggle,
    );
  }
}

class DetailFavoriteIcon extends StatelessWidget {
  final String? roomId;
  final String? buildingId;
  final VoidCallback? onToggle;

  const DetailFavoriteIcon({
    super.key,
    this.roomId,
    this.buildingId,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FavoriteIconButton(
      roomId: roomId,
      buildingId: buildingId,
      size: 28,
      favoriteColor: Colors.red,
      showBackground: true,
      onToggle: onToggle,
    );
  }
}

class CompactFavoriteIcon extends StatelessWidget {
  final String? roomId;
  final String? buildingId;
  final VoidCallback? onToggle;

  const CompactFavoriteIcon({
    super.key,
    this.roomId,
    this.buildingId,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FavoriteIconButton(
      roomId: roomId,
      buildingId: buildingId,
      size: 18,
      favoriteColor: Colors.red,
      showBackground: true,
      onToggle: onToggle,
    );
  }
}