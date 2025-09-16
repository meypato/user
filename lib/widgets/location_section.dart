import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../themes/app_colour.dart';
import '../common/router.dart';
import '../providers/profile_provider.dart';
import '../services/city_service.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;

        return FutureBuilder<String?>(
          future: profile?.cityId != null
              ? CityService.getCityName(profile!.cityId)
              : Future.value('Select City'),
          builder: (context, snapshot) {
            final cityName = snapshot.data ?? 'Loading...';

            return _buildLocationContainer(context, isDark, cityName, profile?.cityId);
          },
        );
      },
    );
  }

  Widget _buildLocationContainer(BuildContext context, bool isDark, String cityName, String? cityId) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryBlue.withValues(alpha: 0.08)
            : AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.primaryBlue.withValues(alpha: 0.3)
              : AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 16,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Location',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '$cityName, AP',
                  style: TextStyle(
                    color: AppColors.getTextPrimary(isDark),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () => _showLocationPicker(context, cityId),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              backgroundColor: isDark
                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                  : AppColors.primaryBlue.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context, String? currentCityId) async {
    // Get provider reference before async operation
    final profileProvider = context.read<ProfileProvider>();

    final result = await context.push(
      '${RoutePaths.locationPicker}?selectedCityId=${currentCityId ?? ""}',
    );

    if (result != null && result is String) {
      // Update the user's profile with the new city ID
      await profileProvider.updateUserCity(result);
    }
  }
}