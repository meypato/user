import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart' hide State;
import '../services/profile_completion_service.dart';
import '../themes/app_colour.dart';

class ProfileCompletionBanner extends StatelessWidget {
  final Profile? profile;
  final VoidCallback? onDismiss;

  const ProfileCompletionBanner({
    super.key,
    required this.profile,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final completionStatus = ProfileCompletionService.getCompletionStatus(profile);
    final percentage = completionStatus['percentage'] as int;
    final missingCount = completionStatus['missingCount'] as int;

    if (completionStatus['isComplete'] as bool) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.9),
            Colors.deepOrange.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCompleteProfile(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Profile completion icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Complete Your Profile',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$missingCount field${missingCount > 1 ? 's' : ''} remaining to unlock all features',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Dismiss button
                    if (onDismiss != null)
                      GestureDetector(
                        onTap: () {
                          ProfileCompletionService.markCompletionBannerShown();
                          onDismiss!();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToCompleteProfile(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Complete Profile',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCompleteProfile(BuildContext context) {
    context.push('/profile/complete');
  }
}

/// Compact version of the completion banner for smaller spaces
class CompactProfileCompletionBanner extends StatelessWidget {
  final Profile? profile;
  final VoidCallback? onDismiss;

  const CompactProfileCompletionBanner({
    super.key,
    required this.profile,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final completionStatus = ProfileCompletionService.getCompletionStatus(profile);
    final percentage = completionStatus['percentage'] as int;

    if (completionStatus['isComplete'] as bool) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.1),
            AppColors.primaryBlue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/profile/complete'),
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                color: AppColors.primaryBlue,
                size: 18,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Complete Profile ($percentage%)',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryBlue,
                size: 14,
              ),

              if (onDismiss != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    ProfileCompletionService.markCompletionBannerShown();
                    onDismiss!();
                  },
                  child: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}