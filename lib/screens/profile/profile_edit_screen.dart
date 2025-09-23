import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_colour.dart';
import '../../models/enums.dart';
import '../../models/reference_models.dart' as ref;
import '../../providers/profile_provider.dart';

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
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.email,
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
  }) {
    return TextFormField(
      controller: controller,
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
              email: _emailController.text,
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

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile saved successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else {
          _showErrorSnackBar('Failed to save profile');
        }
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
}