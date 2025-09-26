import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../themes/app_colour.dart';
import '../../providers/profile_provider.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider = context.read<ProfileProvider>();
      await profileProvider.loadProfile();
      await profileProvider.loadDropdownData(); // Load tribes and professions data

      // Load cities for the profile's state if available
      if (profileProvider.profile?.stateId != null) {
        await profileProvider.loadCitiesForState(profileProvider.profile!.stateId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (profileProvider.isLoading && profileProvider.profile == null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          );
        }

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Profile Details',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Navigate to edit screen
                  context.push('/profile/edit');
                },
                icon: const Icon(
                  Icons.edit,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header Card
                _buildProfileHeaderCard(isDark, profileProvider),
                const SizedBox(height: 16),

                // Personal Information Card
                _buildInformationCard(
                  title: 'Personal Information',
                  isDark: isDark,
                  children: [
                    _buildInfoRow('Full Name', profileProvider.profile?.fullName ?? 'Not provided', Icons.person, isDark),
                    _buildInfoRow('Age', profileProvider.profile?.age?.toString() ?? 'Not provided', Icons.cake, isDark),
                    _buildInfoRow('Date of Birth', profileProvider.profile?.dateOfBirth != null ? _formatDate(profileProvider.profile!.dateOfBirth!) : 'Not provided', Icons.calendar_today, isDark),
                    _buildInfoRow('Gender', profileProvider.profile?.sex?.displayName ?? 'Not provided', Icons.wc, isDark),
                    _buildInfoRow('Phone', profileProvider.profile?.phone ?? 'Not provided', Icons.phone, isDark),
                    _buildInfoRow('Email', profileProvider.profile?.email ?? 'Not provided', Icons.email, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Address Information Card
                _buildInformationCard(
                  title: 'Address Information',
                  isDark: isDark,
                  children: [
                    _buildInfoRow('State', _getStateName(profileProvider), Icons.location_city, isDark),
                    _buildInfoRow('City', _getCityName(profileProvider), Icons.location_on, isDark),
                    _buildInfoRow('Address Line 1', profileProvider.profile?.addressLine1 ?? 'Not provided', Icons.home, isDark),
                    if (profileProvider.profile?.addressLine2?.isNotEmpty == true)
                      _buildInfoRow('Address Line 2', profileProvider.profile!.addressLine2!, Icons.home_outlined, isDark),
                    _buildInfoRow('Pincode', profileProvider.profile?.pincode ?? 'Not provided', Icons.pin_drop, isDark),
                    _buildInfoRow('Country', profileProvider.profile?.country ?? 'India', Icons.flag, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Cultural Information Card
                _buildInformationCard(
                  title: 'Cultural Information',
                  isDark: isDark,
                  children: [
                    _buildInfoRow('APST Status', profileProvider.profile?.apst?.displayName ?? 'Not provided', Icons.verified_user, isDark),
                    _buildInfoRow('Profession', _getProfessionName(profileProvider), Icons.work, isDark),
                    _buildInfoRow('Tribe', _getTribeName(profileProvider), Icons.groups, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Emergency Contact Card
                _buildInformationCard(
                  title: 'Emergency Contact',
                  isDark: isDark,
                  children: [
                    _buildInfoRow('Contact Name', profileProvider.profile?.emergencyContactName ?? 'Not provided', Icons.emergency, isDark),
                    _buildInfoRow('Contact Phone', profileProvider.profile?.emergencyContactPhone ?? 'Not provided', Icons.phone_in_talk, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                // Verification Documents Card
                _buildInformationCard(
                  title: 'Verification Documents',
                  isDark: isDark,
                  children: [
                    _buildDocumentRow('Identification Document', profileProvider.profile?.identificationFileUrl, Icons.badge, isDark),
                    _buildDocumentRow('Police Verification', profileProvider.profile?.policeVerificationFileUrl, Icons.verified, isDark),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeaderCard(bool isDark, ProfileProvider profileProvider) {
    final verificationInfo = profileProvider.getVerificationStatusInfo();
    final completionPercentage = profileProvider.getProfileCompletionPercentage();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Container(
              margin: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(47),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(47),
                child: profileProvider.profile?.photoUrl != null
                    ? Image.network(
                        profileProvider.profile!.photoUrl!,
                        fit: BoxFit.cover,
                        width: 94,
                        height: 94,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.primaryBlue,
                          );
                        },
                      )
                    : const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primaryBlue,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name and Role
          Text(
            profileProvider.profile?.fullName ?? 'Complete Your Profile',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              profileProvider.profile?.role.displayName ?? 'Tenant',
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Verification Status and Progress
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Verification',
                  verificationInfo['text'],
                  _getStatusColor(verificationInfo['color']),
                  _getStatusIcon(verificationInfo['icon']),
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatusItem(
                  'Profile',
                  '$completionPercentage% Complete',
                  completionPercentage >= 80 ? AppColors.success : AppColors.warning,
                  completionPercentage >= 80 ? Icons.check_circle : Icons.pending,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String label, String? documentUrl, IconData icon, bool isDark) {
    final hasDocument = documentUrl?.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (hasDocument ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasDocument ? Icons.check_circle : icon,
              color: hasDocument ? AppColors.success : AppColors.warning,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDocument ? 'Uploaded' : 'Not uploaded',
                  style: TextStyle(
                    color: hasDocument ? AppColors.success : AppColors.warning,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (hasDocument)
            IconButton(
              onPressed: () => _openDocument(documentUrl!),
              icon: Icon(
                Icons.visibility,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  String _getStateName(ProfileProvider profileProvider) {
    if (profileProvider.profile?.stateId == null) {
      return 'Not provided';
    }

    try {
      final state = profileProvider.states.firstWhere(
        (state) => state.id == profileProvider.profile!.stateId,
      );
      return state.name;
    } catch (e) {
      return 'Not provided';
    }
  }

  String _getCityName(ProfileProvider profileProvider) {
    if (profileProvider.profile?.cityId == null) {
      return 'Not provided';
    }

    try {
      final city = profileProvider.cities.firstWhere(
        (city) => city.id == profileProvider.profile!.cityId,
      );
      return city.name;
    } catch (e) {
      return 'Not provided';
    }
  }

  String _getProfessionName(ProfileProvider profileProvider) {
    if (profileProvider.profile?.professionId == null) {
      return 'Not provided';
    }

    try {
      final profession = profileProvider.professions.firstWhere(
        (profession) => profession.id == profileProvider.profile!.professionId,
      );
      return profession.name;
    } catch (e) {
      return 'Not provided';
    }
  }

  String _getTribeName(ProfileProvider profileProvider) {
    if (profileProvider.profile?.tribeId == null) {
      return 'Not provided';
    }

    try {
      final tribe = profileProvider.tribes.firstWhere(
        (tribe) => tribe.id == profileProvider.profile!.tribeId,
      );
      return tribe.name;
    } catch (e) {
      return 'Not provided';
    }
  }

  Color _getStatusColor(String color) {
    switch (color) {
      case 'green':
        return AppColors.success;
      case 'orange':
        return AppColors.warning;
      case 'red':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String icon) {
    switch (icon) {
      case 'verified':
        return Icons.verified;
      case 'pending':
        return Icons.pending;
      case 'error':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  // Open document in browser
  Future<void> _openDocument(String documentUrl) async {
    try {
      final uri = Uri.parse(documentUrl);

      // Open directly in external browser
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to open document. Please check if you have a browser installed.');
      }
    }
  }

  // Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Show error snackbar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}