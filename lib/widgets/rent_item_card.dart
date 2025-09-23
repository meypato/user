import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../themes/app_colour.dart';
import 'favorite_icon_button.dart';

class RentItemCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onTap;
  final bool isFirst;

  const RentItemCard({
    super.key,
    required this.room,
    this.onTap,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isFirst ? 16 : 8,
        bottom: 8,
      ),
      height: 140, // More compact height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? AppColors.surfaceDark
                : Colors.white,
            isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.95)
                : Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.15)
                : AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.grey.shade800.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.8),
            blurRadius: 6,
            offset: const Offset(0, -1),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700.withValues(alpha: 0.2)
              : Colors.grey.shade300.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            context.go('/rent/${room.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // Left side - Image with price overlay (50% of width)
              Expanded(
                flex: 5,
                child: _buildLeftImageSection(isDark),
              ),
              // Right side - Details (50% of width)
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
                  child: _buildRightDetails(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
        ),

        // Subtle separator between items
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                isDark
                    ? Colors.grey.shade700.withValues(alpha: 0.3)
                    : Colors.grey.shade300.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftImageSection(bool isDark) {
    return Stack(
      children: [
        // Large image taking full space
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 140,
            child: room.hasPhotos
                ? Image.network(
                    room.photos.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),
        ),
        
        // Price gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.6),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '₹',
                        style: TextStyle(
                          color: const Color(0xFF00E676), // Vibrant green
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black87,
                            ),
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 8,
                              color: const Color(0xFF00E676).withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: room.fee.toStringAsFixed(0),
                        style: TextStyle(
                          color: const Color(0xFF00E676), // Same vibrant green
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black87,
                            ),
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 8,
                              color: const Color(0xFF00E676).withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                      const TextSpan(
                        text: '/month',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Featured/Popular badge (priority placement)
        if (room.isFeatured || room.isPopular)
          Positioned(
            top: 8,
            left: 8,
            child: _buildFeaturedBadge(),
          ),

        // Favorite icon in top-right corner
        Positioned(
          top: 8,
          right: 8,
          child: CardFavoriteIcon(
            roomId: room.id,
          ),
        ),
      ],
    );
  }

  Widget _buildRightDetails(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Room name and type
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.fullName,
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : const Color(0xFF1A202C),
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Location details with modern styling
            if (room.buildingName != null || room.cityName != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryBlue.withValues(alpha: 0.15)
                      : AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 12,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _buildLocationText(),
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),
            Row(
              children: [
                // Room type chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.category,
                        size: 10,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        room.roomType.displayName,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Occupancy chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.purple.withValues(alpha: 0.15)
                        : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        size: 10,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${room.maximumOccupancy}',
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (room.hasDescription) ...[
              const SizedBox(height: 8),
              Text(
                room.description!,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.15),
            AppColors.primaryBlue.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.home_rounded,
              color: AppColors.primaryBlue.withValues(alpha: 0.7),
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No Image',
            style: TextStyle(
              color: AppColors.primaryBlue.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _buildLocationText() {
    final parts = <String>[];
    if (room.buildingName != null) parts.add(room.buildingName!);
    if (room.cityName != null) parts.add(room.cityName!);
    return parts.join(', ');
  }

  Widget _buildFeaturedBadge() {
    if (room.isFeatured && room.isPopular) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.white,
              size: 10,
            ),
            const SizedBox(width: 2),
            const Text(
              'Featured & Popular',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    } else if (room.isFeatured) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade400,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.white,
              size: 10,
            ),
            const SizedBox(width: 2),
            const Text(
              'Featured',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    } else if (room.isPopular) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 10,
            ),
            const SizedBox(width: 2),
            const Text(
              'Popular',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}