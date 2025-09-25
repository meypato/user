import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  // Dropdown data
  List<State> _states = [];
  List<City> _cities = [];
  List<Profession> _professions = [];
  List<Tribe> _tribes = [];

  // Getters
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;
  List<State> get states => _states;
  List<City> get cities => _cities;
  List<Profession> get professions => _professions;
  List<Tribe> get tribes => _tribes;

  // Check if profile exists
  bool get hasProfile => _profile != null;

  // Check if profile is complete
  bool get isProfileComplete => _profile?.hasCompleteProfile ?? false;

  // Check if user can rent
  bool get canUserRent => _profile?.canRent ?? false;

  // Load current user's profile
  Future<void> loadProfile() async {
    _setLoading(true);
    _clearError();

    try {
      _profile = await ProfileService.getCurrentUserProfile();

      // If profile not found, retry once after 1 second (for new registrations)
      if (_profile == null) {
        await Future.delayed(const Duration(seconds: 1));
        _profile = await ProfileService.getCurrentUserProfile();
      }

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // Create a new profile
  Future<bool> createProfile({
    required String fullName,
    required String email,
    required String phone,
    required String stateId,
    required String cityId,
    int? age,
    SexType? sex,
    String? addressLine1,
    String? addressLine2,
    String? pincode,
    String? professionId,
    String? tribeId,
    APSTStatus? apst,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _profile = await ProfileService.createProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        stateId: stateId,
        cityId: cityId,
        age: age,
        sex: sex,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        pincode: pincode,
        professionId: professionId,
        tribeId: tribeId,
        apst: apst,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update existing profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    int? age,
    SexType? sex,
    String? addressLine1,
    String? addressLine2,
    String? pincode,
    String? stateId,
    String? cityId,
    String? professionId,
    String? tribeId,
    APSTStatus? apst,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    if (_profile == null) return false;

    _setLoading(true);
    _clearError();

    try {
      _profile = await ProfileService.updateProfile(
        profileId: _profile!.id,
        fullName: fullName,
        phone: phone,
        age: age,
        sex: sex,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        pincode: pincode,
        stateId: stateId,
        cityId: cityId,
        professionId: professionId,
        tribeId: tribeId,
        apst: apst,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      );

      _setEditing(false);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Load dropdown data
  Future<void> loadDropdownData() async {
    try {
      // Load states, professions, and tribes in parallel
      final results = await Future.wait([
        ProfileService.getStates(),
        ProfileService.getProfessions(),
        ProfileService.getTribes(),
      ]);

      _states = results[0] as List<State>;
      _professions = results[1] as List<Profession>;
      _tribes = results[2] as List<Tribe>;

      notifyListeners();
    } catch (e) {
      print('ProfileProvider: Error loading dropdown data: $e'); // Debug
      _setError('Failed to load dropdown data: $e');
    }
  }

  // Load cities for a specific state
  Future<void> loadCitiesForState(String stateId) async {
    try {
      _cities = await ProfileService.getCitiesByState(stateId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load cities: $e');
    }
  }

  // Update user's city (for location change)
  Future<bool> updateUserCity(String cityId) async {
    if (_profile == null) return false;

    try {
      final success = await updateProfile(cityId: cityId);
      if (success) {
        // Reload profile to get updated city information
        await loadProfile();
      }
      return success;
    } catch (e) {
      _setError('Failed to update city: $e');
      return false;
    }
  }

  // Toggle edit mode
  void toggleEditMode() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  // Set editing state
  void setEditing(bool editing) {
    _isEditing = editing;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setEditing(bool editing) {
    _isEditing = editing;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Clear profile (for logout)
  void clearProfile() {
    _profile = null;
    _isLoading = false;
    _isEditing = false;
    _errorMessage = null;
    _states.clear();
    _cities.clear();
    _professions.clear();
    _tribes.clear();
    notifyListeners();
  }

  // Get verification status display info
  Map<String, dynamic> getVerificationStatusInfo() {
    if (_profile == null) {
      return {
        'text': 'No Profile',
        'color': 'gray',
        'icon': 'error',
      };
    }

    switch (_profile!.verificationState) {
      case VerificationStatus.unverified:
        return {
          'text': 'Not Verified',
          'color': 'gray',
          'icon': 'pending',
        };
      case VerificationStatus.pending:
        return {
          'text': 'Verification Pending',
          'color': 'orange',
          'icon': 'pending',
        };
      case VerificationStatus.verified:
        return {
          'text': 'Verified',
          'color': 'green',
          'icon': 'verified',
        };
      case VerificationStatus.rejected:
        return {
          'text': 'Verification Rejected',
          'color': 'red',
          'icon': 'error',
        };
    }
  }

  // Get profile completion percentage
  int getProfileCompletionPercentage() {
    if (_profile == null) return 0;

    int completedFields = 0;
    int totalFields = 10; // Essential fields for profile completion

    if (_profile!.fullName.isNotEmpty) completedFields++;
    if (_profile!.phone != null && _profile!.phone!.isNotEmpty) completedFields++;
    if (_profile!.email != null && _profile!.email!.isNotEmpty) completedFields++;
    if (_profile!.age != null) completedFields++;
    if (_profile!.sex != null) completedFields++;
    if (_profile!.addressLine1 != null && _profile!.addressLine1!.isNotEmpty) completedFields++;
    if (_profile!.pincode != null && _profile!.pincode!.isNotEmpty) completedFields++;
    if (_profile!.stateId.isNotEmpty) completedFields++;
    if (_profile!.cityId.isNotEmpty) completedFields++;
    if (_profile!.emergencyContactName != null && _profile!.emergencyContactName!.isNotEmpty) completedFields++;

    return ((completedFields / totalFields) * 100).round();
  }
}