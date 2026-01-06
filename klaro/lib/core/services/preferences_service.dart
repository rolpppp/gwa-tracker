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
final gradingSystemNotifier = ValueNotifier<String>('UP');

// Bridge provider to make grading system reactive in Riverpod
final activeGradingSystemProvider = NotifierProvider<ActiveGradingSystemNotifier, String>(ActiveGradingSystemNotifier.new);

class ActiveGradingSystemNotifier extends Notifier<String> {
  @override
  String build() {
    // Listen to the global notifier
    final notifier = gradingSystemNotifier;
    notifier.addListener(_listener);
    ref.onDispose(() => notifier.removeListener(_listener));
    return notifier.value;
  }
  
  void _listener() {
    state = gradingSystemNotifier.value;
  }
}

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs) {
    // Initialize notifiers
    themeModeNotifier.value = themeMode;
    gradingSystemNotifier.value = selectedGradingSystem;
  }

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyGradingSystem = 'grading_system'; // 'UP', 'US', 'Letter'
  static const _keyUserName = 'user_name';
  static const _keyInstitution = 'user_institution';
  static const _keyThemeMode = 'theme_mode';

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;
  String get selectedGradingSystem => _prefs.getString(_keyGradingSystem) ?? 'UP';
  String get userName => _prefs.getString(_keyUserName) ?? '';
  String get institution => _prefs.getString(_keyInstitution) ?? '';
  String get themeMode => _prefs.getString(_keyThemeMode) ?? 'system';
  
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
}