import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provide the service easily
final preferencesProvider = Provider<PreferencesService>((ref) {
  throw UnimplementedError(); // We initialize this in main.dart
});

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyGradingSystem = 'grading_system'; // 'UP', 'US', 'Letter'
  static const _keyUserName = 'user_name';
  static const _keyInstitution = 'user_institution';

  bool get isOnboardingComplete => _prefs.getBool(_keyOnboardingComplete) ?? false;
  String get selectedGradingSystem => _prefs.getString(_keyGradingSystem) ?? 'UP';
  String get userName => _prefs.getString(_keyUserName) ?? '';
  String get institution => _prefs.getString(_keyInstitution) ?? '';
  
  // Legacy getter for compatibility
  String get gradingSystem => selectedGradingSystem;

  Future<void> completeOnboarding(String system, {String? name, String? institution}) async {
    await _prefs.setString(_keyGradingSystem, system);
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
  }
  
  Future<void> setUserName(String name) async {
    await _prefs.setString(_keyUserName, name);
  }
  
  Future<void> setInstitution(String institution) async {
    await _prefs.setString(_keyInstitution, institution);
  }
  
  Future<void> resetOnboarding() async {
    await _prefs.setBool(_keyOnboardingComplete, false);
  }
}