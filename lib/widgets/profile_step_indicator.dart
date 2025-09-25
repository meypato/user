import 'package:flutter/material.dart';
import '../themes/app_colour.dart';

class ProfileStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProfileStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step Progress Bar
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index == totalSteps - 1 ? 0 : 8,
                ),
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 16),

        // Step Information
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Current Step
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${currentStep + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step ${currentStep + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      _getStepName(currentStep),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Progress Text
            Text(
              '$totalSteps steps total',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress Percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getStepDescription(currentStep),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${((currentStep + 1) / totalSteps * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getStepName(int step) {
    switch (step) {
      case 0:
        return 'Basic Info';
      case 1:
        return 'Address';
      case 2:
        return 'APST Details';
      case 3:
        return 'Emergency';
      default:
        return 'Step ${step + 1}';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Location Details';
      case 2:
        return 'Cultural & Professional Info';
      case 3:
        return 'Safety & Emergency Contact';
      default:
        return 'Complete Profile';
    }
  }
}