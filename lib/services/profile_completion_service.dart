import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for managing profile completion status and tracking
class ProfileCompletionService {
  static const String _completionBannerShownKey = 'completion_banner_shown_';
  static const String _accessPopupShownKey = 'access_popup_shown_';
  static const String _lastCompletionCheckKey = 'last_completion_check';
  static const String _completionReminderCountKey = 'completion_reminder_count';

  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ============================================================================
  // PROFILE COMPLETION ANALYSIS
  // ============================================================================

  /// Check if user has a complete profile for using rental features
  static bool hasCompleteProfileForRenting(Profile? profile) {
    if (profile == null) return false;

    // Basic profile completion
    final hasBasicProfile = profile.hasCompleteProfile;

    // APST-specific requirements for Arunachal Pradesh
    final hasApstInfo = profile.apst != null;

    // Professional classification for access control
    final hasProfession = profile.professionId != null;

    // Emergency contact for tenant safety
    final hasEmergencyContact = profile.emergencyContactName != null &&
                               profile.emergencyContactPhone != null;

    return hasBasicProfile && hasApstInfo && hasProfession && hasEmergencyContact;
  }

  /// Get list of missing required fields for profile completion
  static List<String> getMissingProfileFields(Profile? profile) {
    if (profile == null) {
      return ['Create profile first'];
    }

    List<String> missingFields = [];

    // Basic required fields
    if (profile.fullName.isEmpty) missingFields.add('Full Name');
    if (profile.phone == null || profile.phone!.isEmpty) missingFields.add('Phone Number');
    if (profile.email == null || profile.email!.isEmpty) missingFields.add('Email Address');
    if (profile.age == null) missingFields.add('Age');
    if (profile.sex == null) missingFields.add('Gender');
    if (profile.addressLine1 == null || profile.addressLine1!.isEmpty) missingFields.add('Address');
    if (profile.pincode == null || profile.pincode!.isEmpty) missingFields.add('Pincode');
    if (profile.stateId.isEmpty) missingFields.add('State');
    if (profile.cityId.isEmpty) missingFields.add('City');

    // APST-specific requirements
    if (profile.apst == null) missingFields.add('APST Status');
    if (profile.apst == APSTStatus.apst && profile.tribeId == null) {
      missingFields.add('Tribe Information');
    }

    // Professional information
    if (profile.professionId == null) missingFields.add('Profession');

    // Emergency contact
    if (profile.emergencyContactName == null || profile.emergencyContactName!.isEmpty) {
      missingFields.add('Emergency Contact Name');
    }
    if (profile.emergencyContactPhone == null || profile.emergencyContactPhone!.isEmpty) {
      missingFields.add('Emergency Contact Phone');
    }

    return missingFields;
  }

  /// Get profile completion percentage with APST considerations
  static int getEnhancedCompletionPercentage(Profile? profile) {
    if (profile == null) return 0;

    int completedFields = 0;
    int totalFields = 12; // Total essential fields including APST requirements

    // Basic profile fields (9 fields)
    if (profile.fullName.isNotEmpty) completedFields++;
    if (profile.phone != null && profile.phone!.isNotEmpty) completedFields++;
    if (profile.email != null && profile.email!.isNotEmpty) completedFields++;
    if (profile.age != null) completedFields++;
    if (profile.sex != null) completedFields++;
    if (profile.addressLine1 != null && profile.addressLine1!.isNotEmpty) completedFields++;
    if (profile.pincode != null && profile.pincode!.isNotEmpty) completedFields++;
    if (profile.stateId.isNotEmpty) completedFields++;
    if (profile.cityId.isNotEmpty) completedFields++;

    // APST-specific fields (1 field)
    if (profile.apst != null) completedFields++;

    // Profession field (1 field)
    if (profile.professionId != null) completedFields++;

    // Emergency contact (1 field - counting as single unit)
    if (profile.emergencyContactName != null &&
        profile.emergencyContactName!.isNotEmpty &&
        profile.emergencyContactPhone != null &&
        profile.emergencyContactPhone!.isNotEmpty) {
      completedFields++;
    }

    return ((completedFields / totalFields) * 100).round();
  }

  /// Get profile completion status with detailed breakdown
  static Map<String, dynamic> getCompletionStatus(Profile? profile) {
    final isComplete = hasCompleteProfileForRenting(profile);
    final percentage = getEnhancedCompletionPercentage(profile);
    final missingFields = getMissingProfileFields(profile);

    return {
      'isComplete': isComplete,
      'percentage': percentage,
      'missingFields': missingFields,
      'missingCount': missingFields.length,
      'canAccessRentals': isComplete,
      'nextStepMessage': _getNextStepMessage(missingFields),
    };
  }

  static String _getNextStepMessage(List<String> missingFields) {
    if (missingFields.isEmpty) {
      return 'Profile complete! You can now access all features.';
    }

    if (missingFields.length == 1) {
      return 'Complete your ${missingFields.first} to unlock all features.';
    }

    if (missingFields.length <= 3) {
      return 'Complete ${missingFields.length} more fields to unlock all features.';
    }

    return 'Complete your profile to access rental features.';
  }

  // ============================================================================
  // UI STATE TRACKING
  // ============================================================================

  /// Check if completion banner should be shown
  static bool shouldShowCompletionBanner(Profile? profile) {
    if (hasCompleteProfileForRenting(profile)) return false;

    // Don't spam users - show banner with some intelligence
    final lastCheck = getLastCompletionCheck();
    final now = DateTime.now();

    // Show banner if:
    // 1. Never shown before, OR
    // 2. Last check was more than 24 hours ago, OR
    // 3. Profile has been updated since last check
    if (lastCheck == null ||
        now.difference(lastCheck).inHours > 24 ||
        (profile != null && profile.updatedAt.isAfter(lastCheck))) {
      return true;
    }

    return false;
  }

  /// Check if access popup should be shown for building/rent screens
  static bool shouldShowAccessPopup(Profile? profile) {
    if (hasCompleteProfileForRenting(profile)) return false;

    // Show popup once per session for incomplete profiles
    final sessionKey = 'session_${DateTime.now().day}';
    return !_hasShownPopupInSession(sessionKey);
  }

  /// Mark completion banner as shown
  static Future<void> markCompletionBannerShown() async {
    await initialize();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _prefs!.setInt(_completionBannerShownKey, timestamp);
    await updateLastCompletionCheck();
  }

  /// Mark access popup as shown for current session
  static Future<void> markAccessPopupShown() async {
    await initialize();
    final sessionKey = 'session_${DateTime.now().day}';
    await _prefs!.setBool('$_accessPopupShownKey$sessionKey', true);
  }

  /// Update last completion check timestamp
  static Future<void> updateLastCompletionCheck() async {
    await initialize();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _prefs!.setInt(_lastCompletionCheckKey, timestamp);
  }

  /// Get last completion check timestamp
  static DateTime? getLastCompletionCheck() {
    if (_prefs == null) return null;
    final timestamp = _prefs!.getInt(_lastCompletionCheckKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  static bool _hasShownPopupInSession(String sessionKey) {
    if (_prefs == null) return false;
    return _prefs!.getBool('$_accessPopupShownKey$sessionKey') ?? false;
  }

  // ============================================================================
  // REMINDER AND NOTIFICATION LOGIC
  // ============================================================================

  /// Increment completion reminder count
  static Future<void> incrementReminderCount() async {
    await initialize();
    final current = _prefs!.getInt(_completionReminderCountKey) ?? 0;
    await _prefs!.setInt(_completionReminderCountKey, current + 1);
  }

  /// Get completion reminder count
  static int getReminderCount() {
    if (_prefs == null) return 0;
    return _prefs!.getInt(_completionReminderCountKey) ?? 0;
  }

  /// Reset reminder count (when profile is completed)
  static Future<void> resetReminderCount() async {
    await initialize();
    await _prefs!.remove(_completionReminderCountKey);
  }

  /// Check if user should be gently nudged vs. firmly blocked
  static bool shouldUseGentleNudge(Profile? profile) {
    final reminderCount = getReminderCount();
    final percentage = getEnhancedCompletionPercentage(profile);

    // Use gentle nudge if:
    // 1. Profile is more than 50% complete, OR
    // 2. User hasn't been reminded more than 3 times
    return percentage > 50 || reminderCount <= 3;
  }

  // ============================================================================
  // STEP-BY-STEP COMPLETION GUIDANCE
  // ============================================================================

  /// Get the next recommended step for profile completion
  static Map<String, dynamic> getNextCompletionStep(Profile? profile) {
    if (profile == null) {
      return {
        'step': 1,
        'title': 'Create Your Profile',
        'description': 'Start by creating your basic profile information.',
        'fields': ['Full Name', 'Phone', 'Email'],
        'icon': 'person_add',
      };
    }

    final missingFields = getMissingProfileFields(profile);
    if (missingFields.isEmpty) {
      return {
        'step': 5,
        'title': 'Profile Complete!',
        'description': 'Your profile is complete. You can now access all features.',
        'fields': <String>[],
        'icon': 'check_circle',
      };
    }

    // Determine which step user should focus on next
    final hasBasicInfo = profile.fullName.isNotEmpty &&
                        profile.phone != null &&
                        profile.email != null &&
                        profile.age != null &&
                        profile.sex != null;

    if (!hasBasicInfo) {
      return {
        'step': 1,
        'title': 'Complete Basic Information',
        'description': 'Add your personal details to get started.',
        'fields': ['Full Name', 'Phone', 'Email', 'Age', 'Gender'],
        'icon': 'person',
      };
    }

    final hasAddress = profile.addressLine1 != null &&
                      profile.pincode != null &&
                      profile.stateId.isNotEmpty &&
                      profile.cityId.isNotEmpty;

    if (!hasAddress) {
      return {
        'step': 2,
        'title': 'Add Address Information',
        'description': 'Help us locate properties near you.',
        'fields': ['Address', 'State', 'City', 'Pincode'],
        'icon': 'location_on',
      };
    }

    final hasApstInfo = profile.apst != null && profile.professionId != null;
    if (!hasApstInfo) {
      return {
        'step': 3,
        'title': 'APST & Professional Details',
        'description': 'Required for cultural compatibility matching.',
        'fields': ['APST Status', 'Profession', 'Tribe (if applicable)'],
        'icon': 'work',
      };
    }

    return {
      'step': 4,
      'title': 'Emergency Contact',
      'description': 'Add emergency contact for safety.',
      'fields': ['Emergency Contact Name', 'Emergency Contact Phone'],
      'icon': 'contact_phone',
    };
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Clear all profile completion tracking data
  static Future<void> clearAllTrackingData() async {
    await initialize();

    final keys = _prefs!.getKeys();
    final completionKeys = keys.where((key) =>
      key.startsWith(_completionBannerShownKey) ||
      key.startsWith(_accessPopupShownKey) ||
      key == _lastCompletionCheckKey ||
      key == _completionReminderCountKey
    ).toList();

    for (final key in completionKeys) {
      await _prefs!.remove(key);
    }
  }

  /// Get debug information about completion tracking
  static Map<String, dynamic> getDebugInfo(Profile? profile) {
    return {
      'hasCompleteProfile': hasCompleteProfileForRenting(profile),
      'completionPercentage': getEnhancedCompletionPercentage(profile),
      'missingFields': getMissingProfileFields(profile),
      'shouldShowBanner': shouldShowCompletionBanner(profile),
      'shouldShowPopup': shouldShowAccessPopup(profile),
      'lastCompletionCheck': getLastCompletionCheck()?.toIso8601String(),
      'reminderCount': getReminderCount(),
      'nextStep': getNextCompletionStep(profile),
    };
  }
}