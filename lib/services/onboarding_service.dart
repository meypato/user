import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _onboardingCompletedKey = 'has_completed_onboarding';
  static const String _onboardingVersionKey = 'onboarding_version';
  static const String _tutorialShownKey = 'tutorial_shown_';
  static const String _currentOnboardingVersion = '1.0.0';

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Check if user has completed onboarding
  static bool get hasCompletedOnboarding {
    if (_prefs == null) return false;
    return _prefs!.getBool(_onboardingCompletedKey) ?? false;
  }

  // Check if this is a first-time user
  static bool get isFirstTimeUser {
    return !hasCompletedOnboarding;
  }

  // Mark onboarding as completed
  static Future<bool> completeOnboarding() async {
    await initialize();
    final success = await _prefs!.setBool(_onboardingCompletedKey, true);
    if (success) {
      // Also save the version of onboarding completed
      await _prefs!.setString(_onboardingVersionKey, _currentOnboardingVersion);
    }
    return success;
  }

  // Reset onboarding status (useful for testing or app reset)
  static Future<bool> resetOnboarding() async {
    await initialize();
    final result1 = await _prefs!.remove(_onboardingCompletedKey);
    final result2 = await _prefs!.remove(_onboardingVersionKey);
    return result1 && result2;
  }

  // Get the version of onboarding that was completed
  static String? get completedOnboardingVersion {
    if (_prefs == null) return null;
    return _prefs!.getString(_onboardingVersionKey);
  }

  // Check if onboarding needs to be shown again (version mismatch)
  static bool get shouldShowOnboardingUpdate {
    if (!hasCompletedOnboarding) return true;

    final completedVersion = completedOnboardingVersion;
    return completedVersion == null || completedVersion != _currentOnboardingVersion;
  }

  // Future feature: Track specific tutorial completion
  static Future<bool> markTutorialShown(String tutorialId) async {
    await initialize();
    return await _prefs!.setBool('$_tutorialShownKey$tutorialId', true);
  }

  // Future feature: Check if specific tutorial was shown
  static bool hasTutorialBeenShown(String tutorialId) {
    if (_prefs == null) return false;
    return _prefs!.getBool('$_tutorialShownKey$tutorialId') ?? false;
  }

  // Future feature: Get list of completed tutorials
  static List<String> get completedTutorials {
    if (_prefs == null) return [];

    final keys = _prefs!.getKeys();
    return keys
        .where((key) => key.startsWith(_tutorialShownKey))
        .map((key) => key.replaceFirst(_tutorialShownKey, ''))
        .where((tutorialId) => _prefs!.getBool('$_tutorialShownKey$tutorialId') == true)
        .toList();
  }

  // Debug method: Get all onboarding-related preferences
  static Map<String, dynamic> get debugInfo {
    if (_prefs == null) return {'error': 'Preferences not initialized'};

    return {
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'isFirstTimeUser': isFirstTimeUser,
      'completedVersion': completedOnboardingVersion,
      'currentVersion': _currentOnboardingVersion,
      'shouldShowUpdate': shouldShowOnboardingUpdate,
      'completedTutorials': completedTutorials,
    };
  }

  // Clear all onboarding-related data (useful for app reset)
  static Future<bool> clearAllOnboardingData() async {
    await initialize();

    final keys = _prefs!.getKeys();
    final onboardingKeys = keys.where((key) =>
        key == _onboardingCompletedKey ||
        key == _onboardingVersionKey ||
        key.startsWith(_tutorialShownKey)
    ).toList();

    bool allSuccessful = true;
    for (final key in onboardingKeys) {
      final success = await _prefs!.remove(key);
      if (!success) allSuccessful = false;
    }

    return allSuccessful;
  }
}