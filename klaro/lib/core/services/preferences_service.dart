import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provide the service easily
final preferencesProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError(); // We initialize this in main.dart
});

// Global ValueNotifier for onboarding completion status
final onboardingCompleteNotifier = ValueNotifier<bool>(false);
// Global ValueNotifier for theme mode ('system', 'light', 'dark')
final themeModeNotifier = ValueNotifier<String>('system');
// Global ValueNotifier for grading system
final gradingSystemNotifier = ValueNotifier<String>('5Point');
// Global ValueNotifiers for scholarship mode
final scholarshipModeNotifier = ValueNotifier<bool>(false);
final scholarshipThresholdNotifier = ValueNotifier<double>(2.0);

// Bridge provider to make grading system reactive in Riverpod
final activeGradingSystemProvider = NotifierProvider<ActiveGradingSystemNotifier, String>(ActiveGradingSystemNotifier.new);

// Bridge providers for scholarship mode reactive state
final scholarshipModeProvider = NotifierProvider<ScholarshipModeNotifier, bool>(ScholarshipModeNotifier.new);
final scholarshipThresholdProvider = NotifierProvider<ScholarshipThresholdNotifier, double>(ScholarshipThresholdNotifier.new);

class ActiveGradingSystemNotifier extends Notifier<String> {
  @override
  String build() {
    final notifier = gradingSystemNotifier;
    notifier.addListener(_listener);
    ref.onDispose(() => notifier.removeListener(_listener));
    return notifier.value;
  }

  void _listener() {
    state = gradingSystemNotifier.value;
  }
}

class ScholarshipModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    final notifier = scholarshipModeNotifier;
    notifier.addListener(_listener);
    ref.onDispose(() => notifier.removeListener(_listener));
    return notifier.value;
  }

  void _listener() {
    state = scholarshipModeNotifier.value;
  }
}

class ScholarshipThresholdNotifier extends Notifier<double> {
  @override
  double build() {
    final notifier = scholarshipThresholdNotifier;
    notifier.addListener(_listener);
    ref.onDispose(() => notifier.removeListener(_listener));
    return notifier.value;
  }

  void _listener() {
    state = scholarshipThresholdNotifier.value;
  }
}

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs) {
    // Initialize notifiers
    themeModeNotifier.value = themeMode;
    gradingSystemNotifier.value = selectedGradingSystem;
    scholarshipModeNotifier.value = scholarshipModeEnabled;
    scholarshipThresholdNotifier.value = scholarshipGwaThreshold;
  }

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyGradingSystem = 'grading_system'; // '5Point', '4Point', 'US'
  static const _keyUserName = 'user_name';
  static const _keyInstitution = 'user_institution';
  static const _keyThemeMode = 'theme_mode';
  static const _keyHiddenGradingSystems = 'hidden_grading_systems';
  static const _keyScholarshipModeEnabled = 'scholarship_mode_enabled';
  static const _keyScholarshipGwaThreshold = 'scholarship_gwa_threshold';

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;
  String get selectedGradingSystem => _prefs.getString(_keyGradingSystem) ?? '5Point';
  String get userName => _prefs.getString(_keyUserName) ?? '';
  String get institution => _prefs.getString(_keyInstitution) ?? '';
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  List<String> get hiddenGradingSystems => _prefs.getStringList(_keyHiddenGradingSystems) ?? [];
  bool get scholarshipModeEnabled => _prefs.getBool(_keyScholarshipModeEnabled) ?? false;
  double get scholarshipGwaThreshold => _prefs.getDouble(_keyScholarshipGwaThreshold) ?? 2.0;

  // Legacy getter for compatibility
  String get gradingSystem => selectedGradingSystem;

  Future<void> completeOnboarding(String system, {String? name, String? institution}) async {
    await _prefs.setString(_keyGradingSystem, system);
    gradingSystemNotifier.value = system;
    
    if (name != null && name.isNotEmpty) {
      await _prefs.setString(_keyUserName, name);
    }
    if (institution != null && institution.isNotEmpty) {
      await _prefs.setString(_keyInstitution, institution);
    }
    await _prefs.setBool(_keyOnboardingComplete, true);
  }
  
  Future<void> setGradingSystem(String system) async {
    await _prefs.setString(_keyGradingSystem, system);
    gradingSystemNotifier.value = system;
  }
  
  Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }
  
  Future<void> setInstitution(String institution) async {
    await _prefs.setString(_keyInstitution, institution);
  }

  Future<void> setThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
    themeModeNotifier.value = mode;
  }
  
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_keyOnboardingComplete, false);
  }
  
  Future<void> setHiddenGradingSystems(List<String> hiddenSystems) async {
    await _prefs.setStringList(_keyHiddenGradingSystems, hiddenSystems);
  }

  Future<void> toggleGradingSystemVisibility(String system) async {
    final hidden = hiddenGradingSystems;
    if (hidden.contains(system)) {
      hidden.remove(system);
    } else {
      hidden.add(system);
    }
    await setHiddenGradingSystems(hidden);
  }

  Future<void> setScholarshipModeEnabled(bool enabled) async {
    await _prefs.setBool(_keyScholarshipModeEnabled, enabled);
    scholarshipModeNotifier.value = enabled;
  }

  Future<void> setScholarshipGwaThreshold(double threshold) async {
    await _prefs.setDouble(_keyScholarshipGwaThreshold, threshold);
    scholarshipThresholdNotifier.value = threshold;
  }
}