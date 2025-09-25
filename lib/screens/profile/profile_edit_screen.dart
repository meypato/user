import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meypato/services/profile_document_service.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../themes/app_colour.dart';
import '../../models/enums.dart';
import '../../models/reference_models.dart' as ref;
import '../../providers/profile_provider.dart';
import '../../services/profile_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
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
  ref.State? _selectedState;
  ref.City? _selectedCity;
  ref.Profession? _selectedProfession;
  ref.Tribe? _selectedTribe;

  bool _isLoading = false;

  // Photo and document upload variables
  File? _selectedPhoto;
  XFile? _selectedPhotoXFile;
  bool _photoChanged = false;
  bool _isUploadingPhoto = false;

  File? _selectedIdDocument;
  bool _idDocumentChanged = false;
  bool _isUploadingId = false;

  File? _selectedPoliceDocument;
  bool _policeDocumentChanged = false;
  bool _isUploadingPolice = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = context.read<ProfileProvider>();
      profileProvider.loadProfile();
      profileProvider.loadDropdownData();
      _populateFields(profileProvider.profile);
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

  void _populateFields(profile) {
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

      // Set selected state and city from profile
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final profileProvider = context.read<ProfileProvider>();

        if (profileProvider.states.isNotEmpty) {
          try {
            _selectedState = profileProvider.states.firstWhere(
              (state) => state.id == profile.stateId,
            );
          } catch (e) {
            _selectedState = null;
          }
        }

        if (profileProvider.cities.isNotEmpty) {
          try {
            _selectedCity = profileProvider.cities.firstWhere(
              (city) => city.id == profile.cityId,
            );
          } catch (e) {
            _selectedCity = null;
          }
        }

        // Set profession and tribe
        if (profile.professionId != null && profileProvider.professions.isNotEmpty) {
          try {
            _selectedProfession = profileProvider.professions.firstWhere(
              (profession) => profession.id == profile.professionId,
            );
          } catch (e) {
            _selectedProfession = null;
          }
        }

        if (profile.tribeId != null && profileProvider.tribes.isNotEmpty) {
          try {
            _selectedTribe = profileProvider.tribes.firstWhere(
              (tribe) => tribe.id == profile.tribeId,
            );
          } catch (e) {
            _selectedTribe = null;
          }
        }

        if (mounted) setState(() {});
      });
    }
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
              'Edit Profile',
              style: TextStyle(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Personal Information
                  _buildSectionCard(
                    title: 'Personal Information',
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        icon: Icons.person,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _ageController,
                              label: 'Age',
                              icon: Icons.cake,
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<SexType>(
                              value: _selectedSex,
                              label: 'Gender',
                              icon: Icons.wc,
                              items: SexType.values,
                              itemLabel: (sex) => sex.displayName,
                              onChanged: (value) => setState(() => _selectedSex = value),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Profile Photo Section
                  _buildProfilePhotoSection(profileProvider, isDark),
                  const SizedBox(height: 16),

                  // Contact Information
                  _buildSectionCard(
                    title: 'Contact Information',
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value!)) return 'Invalid phone';
                          return null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      // Email field is read-only to prevent auth issues
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address (Read-only)',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Disable email editing to prevent auth conflicts
                        validator: null, // Remove validation for read-only field
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Location Information
                  _buildSectionCard(
                    title: 'Location Information',
                    isDark: isDark,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<ref.State>(
                              value: _selectedState,
                              label: 'State',
                              icon: Icons.location_city,
                              items: profileProvider.states,
                              itemLabel: (state) => state.name,
                              onChanged: (value) {
                                setState(() {
                                  _selectedState = value;
                                  _selectedCity = null; // Reset city when state changes
                                });
                                if (value != null) {
                                  profileProvider.loadCitiesForState(value.id);
                                }
                              },
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<ref.City>(
                              value: _selectedCity,
                              label: 'City',
                              icon: Icons.location_on,
                              items: profileProvider.cities,
                              itemLabel: (city) => city.name,
                              onChanged: (value) => setState(() => _selectedCity = value),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressLine1Controller,
                        label: 'Address Line 1',
                        icon: Icons.home,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _addressLine2Controller,
                        label: 'Address Line 2 (Optional)',
                        icon: Icons.home_outlined,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        icon: Icons.location_on,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (!RegExp(r'^[0-9]{6}$').hasMatch(value!)) return 'Invalid pincode';
                          return null;
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cultural Information
                  _buildSectionCard(
                    title: 'Cultural Information',
                    isDark: isDark,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown<ref.Profession>(
                              value: _selectedProfession,
                              label: 'Profession',
                              icon: Icons.work,
                              items: profileProvider.professions,
                              itemLabel: (profession) => profession.name,
                              onChanged: (value) => setState(() => _selectedProfession = value),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown<ref.Tribe>(
                              value: _selectedTribe,
                              label: 'Tribe',
                              icon: Icons.groups,
                              items: profileProvider.tribes,
                              itemLabel: (tribe) => tribe.name,
                              onChanged: (value) => setState(() => _selectedTribe = value),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<APSTStatus>(
                        value: _selectedApstStatus,
                        label: 'APST Status',
                        icon: Icons.verified_user,
                        items: APSTStatus.values,
                        itemLabel: (status) => status.displayName,
                        onChanged: (value) => setState(() => _selectedApstStatus = value),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Emergency Contact
                  _buildSectionCard(
                    title: 'Emergency Contact',
                    isDark: isDark,
                    children: [
                      _buildTextField(
                        controller: _emergencyNameController,
                        label: 'Emergency Contact Name',
                        icon: Icons.emergency,
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _emergencyPhoneController,
                        label: 'Emergency Contact Phone',
                        icon: Icons.phone_in_talk,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value!)) return 'Invalid phone';
                          return null;
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Legal Documents Section
                  _buildDocumentsSection(profileProvider, isDark),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _saveProfile(profileProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      style: TextStyle(
        color: enabled
            ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
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

  Future<void> _saveProfile(ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required selections
    if (_selectedState == null) {
      _showErrorSnackBar('Please select a state');
      return;
    }
    if (_selectedCity == null) {
      _showErrorSnackBar('Please select a city');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // First save the profile data
      final success = profileProvider.hasProfile
          ? await profileProvider.updateProfile(
              fullName: _fullNameController.text,
              phone: _phoneController.text,
              age: int.tryParse(_ageController.text),
              sex: _selectedSex,
              addressLine1: _addressLine1Controller.text,
              addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
              pincode: _pincodeController.text,
              stateId: _selectedState!.id,
              cityId: _selectedCity!.id,
              professionId: _selectedProfession?.id,
              tribeId: _selectedTribe?.id,
              apst: _selectedApstStatus,
              emergencyContactName: _emergencyNameController.text,
              emergencyContactPhone: _emergencyPhoneController.text,
            )
          : await profileProvider.createProfile(
              fullName: _fullNameController.text,
              email: _emailController.text, // Keep email for profile creation
              phone: _phoneController.text,
              stateId: _selectedState!.id,
              cityId: _selectedCity!.id,
              age: int.tryParse(_ageController.text),
              sex: _selectedSex,
              addressLine1: _addressLine1Controller.text,
              addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
              pincode: _pincodeController.text,
              professionId: _selectedProfession?.id,
              tribeId: _selectedTribe?.id,
              apst: _selectedApstStatus,
              emergencyContactName: _emergencyNameController.text,
              emergencyContactPhone: _emergencyPhoneController.text,
            );

      if (!success) {
        _showErrorSnackBar('Failed to save profile');
        return;
      }

      // Upload files if changed and profile save was successful
      final profile = profileProvider.profile;
      if (profile != null) {
        // Upload profile photo if changed
        if (_photoChanged) {
          setState(() => _isUploadingPhoto = true);

          try {
            if (_selectedPhoto != null && _selectedPhotoXFile != null) {
              final photoUrl = await ProfileService.updateProfilePhotoMobile(
                userId: profile.id,
                imageFile: _selectedPhotoXFile!,
                currentPhotoUrl: profile.photoUrl,
              );

              if (photoUrl != null) {
                // Update profile in provider with new photo URL
                await profileProvider.loadProfile(); // Refresh to get updated data
              }
            } else if (_selectedPhoto == null && profile.photoUrl != null) {
              // Remove photo
              final removed = await ProfileService.removeProfilePhoto(
                userId: profile.id,
                photoUrl: profile.photoUrl!,
              );

              if (removed) {
                await profileProvider.loadProfile(); // Refresh to get updated data
              }
            }
          } catch (e) {
            _showErrorSnackBar('Failed to update profile photo: $e');
          } finally {
            setState(() => _isUploadingPhoto = false);
          }
        }

        // Upload identification document if changed
        if (_idDocumentChanged) {
          setState(() => _isUploadingId = true);

          try {
            if (_selectedIdDocument != null) {
              final documentUrl = await ProfileService.updateIdentificationDocument(
                userId: profile.id,
                documentFile: _selectedIdDocument!,
                currentDocumentUrl: profile.identificationFileUrl,
              );

              if (documentUrl != null) {
                await profileProvider.loadProfile(); // Refresh to get updated data
              }
            } else if (_selectedIdDocument == null && profile.identificationFileUrl != null) {
              // Remove document
              final removed = await ProfileService.removeIdentificationDocument(
                userId: profile.id,
                documentUrl: profile.identificationFileUrl!,
              );

              if (removed) {
                await profileProvider.loadProfile(); // Refresh to get updated data
              }
            }
          } catch (e) {
            _showErrorSnackBar('Failed to update identification document: $e');
          } finally {
            setState(() => _isUploadingId = false);
          }
        }

        // Upload police verification document if changed
        if (_policeDocumentChanged) {
          setState(() => _isUploadingPolice = true);

          try {
            if (_selectedPoliceDocument != null) {
              final documentUrl = await ProfileService.updatePoliceVerificationDocument(
                userId: profile.id,
                documentFile: _selectedPoliceDocument!,
                currentDocumentUrl: profile.policeVerificationFileUrl,
              );

              if (documentUrl != null) {
                await profileProvider.loadProfile(); // Refresh to get updated data
              }
            } else if (_selectedPoliceDocument == null && profile.policeVerificationFileUrl != null) {
              // Remove document
              final removed = await ProfileService.removePoliceVerificationDocument(
                userId: profile.id,
                documentUrl: profile.policeVerificationFileUrl!,
              );

              if (removed) {
                await profileProvider.loadProfile(); // Refresh to get updated data
              }
            }
          } catch (e) {
            _showErrorSnackBar('Failed to update police verification document: $e');
          } finally {
            setState(() => _isUploadingPolice = false);
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

  // Build Profile Photo Section
  Widget _buildProfilePhotoSection(ProfileProvider profileProvider, bool isDark) {
    final profile = profileProvider.profile;
    final currentPhotoUrl = profile?.photoUrl;

    return _buildSectionCard(
      title: 'Profile Photo',
      isDark: isDark,
      children: [
        Row(
          children: [
            // Photo Display
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _selectedPhoto != null
                    ? Image.file(
                        _selectedPhoto!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : currentPhotoUrl != null && currentPhotoUrl.isNotEmpty
                        ? Image.network(
                            currentPhotoUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: 80,
                                height: 80,
                                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 16),
            // Upload Buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Photo',
                    style: TextStyle(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max 2MB • JPG, PNG supported',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploadingPhoto ? null : _pickProfilePhoto,
                          icon: _isUploadingPhoto
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.camera_alt, size: 16),
                          label: Text(_isUploadingPhoto ? 'Uploading...' : 'Change'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (currentPhotoUrl != null || _selectedPhoto != null)
                        ElevatedButton.icon(
                          onPressed: _isUploadingPhoto ? null : _removeProfilePhoto,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Remove'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build Documents Section
  Widget _buildDocumentsSection(ProfileProvider profileProvider, bool isDark) {
    final profile = profileProvider.profile;

    return _buildSectionCard(
      title: 'Legal Documents',
      isDark: isDark,
      children: [
        // Identification Document
        _buildDocumentRow(
          title: 'Identification Document',
          description: 'Upload government-issued ID (Aadhaar, PAN, Passport, etc.)',
          currentUrl: profile?.identificationFileUrl,
          selectedFile: _selectedIdDocument,
          isUploading: _isUploadingId,
          onPick: () => _pickDocument(DocumentType.identification),
          onRemove: () => _removeDocument(DocumentType.identification),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        // Police Verification Document
        _buildDocumentRow(
          title: 'Police Verification Certificate',
          description: 'Upload police verification certificate for rental eligibility',
          currentUrl: profile?.policeVerificationFileUrl,
          selectedFile: _selectedPoliceDocument,
          isUploading: _isUploadingPolice,
          onPick: () => _pickDocument(DocumentType.policeVerification),
          onRemove: () => _removeDocument(DocumentType.policeVerification),
          isDark: isDark,
        ),
      ],
    );
  }

  // Build Document Row
  Widget _buildDocumentRow({
    required String title,
    required String description,
    String? currentUrl,
    File? selectedFile,
    required bool isUploading,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    required bool isDark,
  }) {
    final hasDocument = currentUrl != null && currentUrl.isNotEmpty || selectedFile != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDarkSecondary : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasDocument ? Icons.check_circle : Icons.upload_file,
                color: hasDocument ? AppColors.success : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (selectedFile != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFile.path.split('/').last,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUploading ? null : onPick,
                  icon: isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file, size: 16),
                  label: Text(
                    isUploading
                        ? 'Uploading...'
                        : hasDocument
                            ? 'Replace'
                            : 'Upload',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (hasDocument) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: isUploading ? null : onRemove,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remove'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Photo Upload Methods
  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final File imageFile = File(image.path);

        // Basic validation (we'll let the service handle detailed validation)
        if (imageFile.lengthSync() <= 2 * 1024 * 1024) { // 2MB limit
          setState(() {
            _selectedPhoto = imageFile;
            _selectedPhotoXFile = image;
            _photoChanged = true;
          });
        } else {
          _showErrorSnackBar('Please select a valid image file (max 2MB, JPG/PNG)');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image: $e');
    }
  }

  Future<void> _removeProfilePhoto() async {
    setState(() {
      _selectedPhoto = null;
      _selectedPhotoXFile = null;
      _photoChanged = true;
    });
  }

  // Document Upload Methods
  Future<void> _pickDocument(DocumentType documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);

        if (file.lengthSync() <= 10 * 1024 * 1024) { // 10MB limit
          setState(() {
            if (documentType == DocumentType.identification) {
              _selectedIdDocument = file;
              _idDocumentChanged = true;
            } else {
              _selectedPoliceDocument = file;
              _policeDocumentChanged = true;
            }
          });
        } else {
          _showErrorSnackBar('Invalid document file. Max size 10MB, PDF/DOC/DOCX/JPG/PNG supported.');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick document: $e');
    }
  }

  Future<void> _removeDocument(DocumentType documentType) async {
    setState(() {
      if (documentType == DocumentType.identification) {
        _selectedIdDocument = null;
        _idDocumentChanged = true;
      } else {
        _selectedPoliceDocument = null;
        _policeDocumentChanged = true;
      }
    });
  }
}