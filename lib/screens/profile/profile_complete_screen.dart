import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart' hide State;
import '../../providers/profile_provider.dart';
import '../../services/profile_completion_service.dart';
import '../../themes/app_colour.dart';
import '../../widgets/profile_step_indicator.dart';

class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({super.key});

  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 4;

  // Form keys for each step
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // Step 1: Basic Info
    GlobalKey<FormState>(), // Step 2: Address
    GlobalKey<FormState>(), // Step 3: APST Details
    GlobalKey<FormState>(), // Step 4: Emergency Contact
  ];

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

  // Dropdown selections
  SexType? _selectedSex;
  APSTStatus? _selectedApstStatus;
  String? _selectedStateId;
  String? _selectedCityId;
  String? _selectedProfessionId;
  String? _selectedTribeId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _pincodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _loadExistingProfile() {
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

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
      _selectedStateId = profile.stateId;
      _selectedCityId = profile.cityId;
      _selectedProfessionId = profile.professionId;
      _selectedTribeId = profile.tribeId;

      // Auto-load cities if state is pre-selected
      if (_selectedStateId != null && _selectedStateId!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final profileProvider = context.read<ProfileProvider>();
          profileProvider.loadCitiesForState(_selectedStateId!);
        });
      }
    }
  }

  void _loadDropdownData() {
    final profileProvider = context.read<ProfileProvider>();
    profileProvider.loadDropdownData();
  }

  void _nextStep() {
    // Dismiss keyboard before proceeding
    FocusScope.of(context).unfocus();

    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps - 1) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _completeProfile();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    return _formKeys[_currentStep].currentState?.validate() ?? false;
  }

  Future<void> _completeProfile() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
    });

    final profileProvider = context.read<ProfileProvider>();

    // Determine if this is create or update
    final isUpdate = profileProvider.profile != null;

    bool success;
    if (isUpdate) {
      success = await profileProvider.updateProfile(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        age: int.tryParse(_ageController.text),
        sex: _selectedSex,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
        pincode: _pincodeController.text,
        stateId: _selectedStateId,
        cityId: _selectedCityId,
        professionId: _selectedProfessionId,
        tribeId: _selectedTribeId,
        apst: _selectedApstStatus,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text,
      );
    } else {
      success = await profileProvider.createProfile(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        stateId: _selectedStateId!,
        cityId: _selectedCityId!,
        age: int.tryParse(_ageController.text),
        sex: _selectedSex,
        addressLine1: _addressLine1Controller.text,
        addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
        pincode: _pincodeController.text,
        professionId: _selectedProfessionId,
        tribeId: _selectedTribeId,
        apst: _selectedApstStatus,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Reset completion tracking
      await ProfileCompletionService.resetReminderCount();

      // Show success and navigate
      if (mounted) {
        _showSuccessDialog();
      }
    } else {
      // Show error
      if (mounted) {
        _showErrorSnackbar(profileProvider.errorMessage ?? 'Failed to save profile');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            const Text('Profile Complete!'),
          ],
        ),
        content: const Text(
          'Your profile has been completed successfully. You can now access all features of the app.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Complete Profile',
          style: TextStyle(
            color: theme.brightness == Brightness.dark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: theme.brightness == Brightness.dark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimary,
        ),
        leading: _currentStep > 0
            ? IconButton(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
              )
            : IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close),
              ),
      ),
      body: Column(
        children: [
          // Step Indicator
          Padding(
            padding: const EdgeInsets.all(20),
            child: ProfileStepIndicator(
              currentStep: _currentStep,
              totalSteps: _totalSteps,
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildAddressStep(),
                _buildApstStep(),
                _buildEmergencyStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Basic Information',
              'Tell us about yourself',
              Icons.person,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _fullNameController,
              decoration: _buildInputDecoration('Full Name *'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: _buildInputDecoration('Phone Number *'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: _buildInputDecoration('Email Address *'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: _buildInputDecoration('Age *'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 18 || age > 120) {
                        return 'Please enter a valid age (18-120)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<ProfileProvider>(
                    builder: (context, provider, child) {
                      return DropdownButtonFormField<SexType>(
                        value: _selectedSex,
                        decoration: _buildInputDecoration('Gender *'),
                        items: SexType.values.map((sex) {
                          return DropdownMenuItem(
                            value: sex,
                            child: Text(sex.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSex = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Address Information',
              'Help us locate properties near you',
              Icons.location_on,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _addressLine1Controller,
              decoration: _buildInputDecoration('Address Line 1 *'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _addressLine2Controller,
              decoration: _buildInputDecoration('Address Line 2 (Optional)'),
            ),
            const SizedBox(height: 16),

            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedStateId,
                  decoration: _buildInputDecoration('State *'),
                  items: [
                    // Default option
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text(
                        'Select state',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    // State options
                    ...provider.states.map((state) {
                      return DropdownMenuItem(
                        value: state.id,
                        child: Text(state.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStateId = value;
                      _selectedCityId = null;
                    });
                    if (value != null) {
                      provider.loadCitiesForState(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your state';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedCityId,
                  decoration: _buildInputDecoration('City *'),
                  items: provider.cities.map((city) {
                    return DropdownMenuItem(
                      value: city.id,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCityId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your city';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _pincodeController,
              decoration: _buildInputDecoration('Pincode *'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your pincode';
                }
                if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                  return 'Please enter a valid 6-digit pincode';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApstStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'APST & Professional Details',
              'Required for cultural compatibility matching',
              Icons.work,
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<APSTStatus>(
              value: _selectedApstStatus,
              decoration: _buildInputDecoration('APST Status *'),
              items: APSTStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedApstStatus = value;
                  if (value != APSTStatus.apst) {
                    _selectedTribeId = null;
                  }
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select your APST status';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            if (_selectedApstStatus == APSTStatus.apst) ...[
              Consumer<ProfileProvider>(
                builder: (context, provider, child) {
                  return DropdownButtonFormField<String>(
                    value: _selectedTribeId,
                    decoration: _buildInputDecoration('Tribe *'),
                    items: provider.tribes.map((tribe) {
                      return DropdownMenuItem(
                        value: tribe.id,
                        child: Text(tribe.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTribeId = value;
                      });
                    },
                    validator: (value) {
                      if (_selectedApstStatus == APSTStatus.apst && value == null) {
                        return 'Please select your tribe';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                return DropdownButtonFormField<String>(
                  value: _selectedProfessionId,
                  decoration: _buildInputDecoration('Profession *'),
                  items: provider.professions.map((profession) {
                    return DropdownMenuItem(
                      value: profession.id,
                      child: Text(profession.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProfessionId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your profession';
                    }
                    return null;
                  },
                );
              },
            ),

            if (_selectedApstStatus == APSTStatus.apst) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This information helps landlords find tenants who match their cultural preferences.',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Emergency Contact',
              'For your safety and security',
              Icons.contact_phone,
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: _emergencyNameController,
              decoration: _buildInputDecoration('Emergency Contact Name *'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter emergency contact name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emergencyPhoneController,
              decoration: _buildInputDecoration('Emergency Contact Phone *'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter emergency contact phone';
                }
                if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value)) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Emergency contact information is kept private and only used in case of emergencies.',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.1),
                    AppColors.primaryBlue.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.celebration,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You\'re Almost Done!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your profile to unlock all features and start finding your perfect home.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryBlue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentStep == _totalSteps - 1 ? 'Complete Profile' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_currentStep < _totalSteps - 1) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}