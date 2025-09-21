import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../themes/app_colour.dart';
import 'favorite_icon_button.dart';

class CompactRoomCard extends StatelessWidget {
  final Room room;
  final String? buildingId;
  final VoidCallback? onTap;

  const CompactRoomCard({
    super.key,
    required this.room,
    this.buildingId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.05)
                : AppColors.primaryBlue.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {
            if (buildingId != null) {
              context.go('/building/$buildingId/room/${room.id}');
            } else {
              context.go('/rent/${room.id}');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Left side - Small image/placeholder (20% width)
                _buildCompactImage(isDark),

                const SizedBox(width: 12),

                // Middle - Room details (60% width)
                Expanded(
                  flex: 3,
                  child: _buildRoomInfo(theme, isDark),
                ),

                // Right side - Price (20% width)
                _buildPriceSection(theme, isDark),

                const SizedBox(width: 8),

                // Favorite icon
                CompactFavoriteIcon(
                  roomId: room.id,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactImage(bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.1),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.bed,
          color: AppColors.primaryBlue.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRoomInfo(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Room name
        Text(
          room.fullName,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Room details in compact chips
        Row(
          children: [
            // Room type chip
            _buildCompactChip(
              icon: Icons.category,
              text: room.roomType.displayName,
              color: Colors.orange,
            ),

            const SizedBox(width: 6),

            // Occupancy chip
            _buildCompactChip(
              icon: Icons.people,
              text: '${room.maximumOccupancy}',
              color: Colors.purple,
            ),

            const SizedBox(width: 6),

            // Availability status
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: room.isAvailable ? AppColors.success : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 8,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(ThemeData theme, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Price
        RichText(
          textAlign: TextAlign.right,
          text: TextSpan(
            children: [
              TextSpan(
                text: '₹',
                style: TextStyle(
                  color: const Color(0xFF00E676),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: room.fee.toStringAsFixed(0),
                style: TextStyle(
                  color: const Color(0xFF00E676),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        // Per month text
        Text(
          '/month',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Security deposit if available
        if (room.hasSecurityFee) ...[
          const SizedBox(height: 4),
          Text(
            '+₹${room.securityFee?.toStringAsFixed(0) ?? '0'}',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}