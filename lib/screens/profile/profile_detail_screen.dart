import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colour.dart';
import '../../models/enums.dart';
import '../../models/profile.dart';
import '../../providers/profile_provider.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _pincodeController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // Dropdown values
  SexType? _selectedSex;
  APSTStatus? _selectedApstStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.loadProfile();
      profileProvider.loadDropdownData();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _pincodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _populateFields(Profile? profile) {
    if (profile != null) {
      _fullNameController.text = profile.fullName;
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';
      _ageController.text = profile.age?.toString() ?? '';
      _addressLine1Controller.text = profile.addressLine1 ?? '';
      _addressLine2Controller.text = profile.addressLine2 ?? '';
      _pincodeController.text = profile.pincode ?? '';
      _emergencyNameController.text = profile.emergencyContactName ?? '';
      _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';
      _selectedSex = profile.sex;
      _selectedApstStatus = profile.apst;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        _populateFields(profileProvider.profile);

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
              TextButton(
                onPressed: () => profileProvider.toggleEditMode(),
                child: Text(
                  profileProvider.isEditing ? 'Cancel' : 'Edit',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeaderCard(isDark, profileProvider),
                  const SizedBox(height: 16),

                  // Profile Form
                  _buildProfileForm(isDark, profileProvider),
                ],
              ),
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
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(37),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(37),
                    child: profileProvider.profile?.photoUrl != null
                        ? Image.network(
                            profileProvider.profile!.photoUrl!,
                            fit: BoxFit.cover,
                            width: 74,
                            height: 74,
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
                                size: 40,
                                color: AppColors.primaryBlue,
                              );
                            },
                          )
                        : const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primaryBlue,
                          ),
                  ),
                ),
              ),
              if (profileProvider.isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Name and Role
          Text(
            profileProvider.profile?.fullName ?? 'Complete Your Profile',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2),
              ),
            ),
            child: const Text(
              'Tenant',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

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
              const SizedBox(width: 12),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(bool isDark, ProfileProvider profileProvider) {
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
          // Personal Information
          _buildSectionTitle('Personal Information', isDark),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            icon: Icons.person,
            enabled: profileProvider.isEditing,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.cake,
                  enabled: profileProvider.isEditing,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    final age = int.tryParse(value!);
                    if (age == null || age < 18 || age > 120) return 'Invalid age';
                    return null;
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown<SexType>(
                  value: _selectedSex,
                  label: 'Gender',
                  icon: Icons.wc,
                  items: SexType.values,
                  itemLabel: (sex) => sex.displayName,
                  onChanged: profileProvider.isEditing
                      ? (value) => setState(() => _selectedSex = value)
                      : null,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact Information
          _buildSectionTitle('Contact Information', isDark),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            enabled: profileProvider.isEditing,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value!)) return 'Invalid phone';
              return null;
            },
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email,
            enabled: profileProvider.isEditing,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(value!)) {
                return 'Invalid email';
              }
              return null;
            },
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Address Information
          _buildSectionTitle('Address Information', isDark),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _addressLine1Controller,
            label: 'Address Line 1',
            icon: Icons.home,
            enabled: profileProvider.isEditing,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _addressLine2Controller,
            label: 'Address Line 2 (Optional)',
            icon: Icons.home_outlined,
            enabled: profileProvider.isEditing,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  icon: Icons.location_on,
                  enabled: profileProvider.isEditing,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required';
                    if (!RegExp(r'^[0-9]{6}$').hasMatch(value!)) return 'Invalid pincode';
                    return null;
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundDarkSecondary : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'India',
                        style: TextStyle(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cultural Information
          _buildSectionTitle('Cultural Information', isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPlaceholderField('Profession', Icons.work, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildPlaceholderField('Tribe', Icons.groups, isDark)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdown<APSTStatus>(
            value: _selectedApstStatus,
            label: 'APST Status',
            icon: Icons.verified_user,
            items: APSTStatus.values,
            itemLabel: (status) => status.displayName,
            onChanged: profileProvider.isEditing
                ? (value) => setState(() => _selectedApstStatus = value)
                : null,
            isDark: isDark,
          ),
          const SizedBox(height: 16),

          // Emergency Contact
          _buildSectionTitle('Emergency Contact', isDark),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emergencyNameController,
            label: 'Emergency Contact Name',
            icon: Icons.emergency,
            enabled: profileProvider.isEditing,
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _emergencyPhoneController,
            label: 'Emergency Contact Phone',
            icon: Icons.phone_in_talk,
            enabled: profileProvider.isEditing,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Required';
              if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value!)) return 'Invalid phone';
              return null;
            },
            isDark: isDark,
          ),
          const SizedBox(height: 20),

          // Save Button
          if (profileProvider.isEditing)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: profileProvider.isLoading ? null : () => _saveProfile(profileProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: profileProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? AppColors.backgroundDarkSecondary : AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemLabel,
    required bool isDark,
    void Function(T?)? onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(
          itemLabel(item),
          style: const TextStyle(fontSize: 14),
        ),
      )).toList(),
      style: TextStyle(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: isDark ? AppColors.backgroundDarkSecondary : AppColors.backgroundSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 2,
          ),
        ),
      ),
      dropdownColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
    );
  }

  Widget _buildPlaceholderField(String label, IconData icon, bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDarkSecondary : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '$label (Soon)',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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

  Future<void> _saveProfile(ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final success = profileProvider.hasProfile
        ? await profileProvider.updateProfile(
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            age: int.tryParse(_ageController.text),
            sex: _selectedSex,
            addressLine1: _addressLine1Controller.text,
            addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
            pincode: _pincodeController.text,
            apst: _selectedApstStatus,
            emergencyContactName: _emergencyNameController.text,
            emergencyContactPhone: _emergencyPhoneController.text,
          )
        : await profileProvider.createProfile(
            fullName: _fullNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            stateId: 'temp-state-id', // TODO: Implement state/city selection
            cityId: 'temp-city-id',
            age: int.tryParse(_ageController.text),
            sex: _selectedSex,
            addressLine1: _addressLine1Controller.text,
            addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
            pincode: _pincodeController.text,
            apst: _selectedApstStatus,
            emergencyContactName: _emergencyNameController.text,
            emergencyContactPhone: _emergencyPhoneController.text,
          );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile saved successfully!' : 'Failed to save profile'),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}