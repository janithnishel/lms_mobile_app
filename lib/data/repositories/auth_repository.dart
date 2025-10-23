// lib/data/repositories/auth_repository.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 💡 අලුතින් එකතු කළා

class AuthRepository {
  final storage = const FlutterSecureStorage();
  final String _tokenKey = 'auth_token'; 
  final String _onboardingKey = 'onboarding_seen'; // 💡 අලුත් Key

  // -----------------------------------------------------------------
  // 🔑 Token Management (කලින් තිබූ කේතය)
  // -----------------------------------------------------------------
  Future<void> saveToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return await storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: _tokenKey);
  }

  // -----------------------------------------------------------------
  // 🆕 Onboarding Management
  // -----------------------------------------------------------------

  // 1. Onboarding එක දැකලාද කියලා කියවන්න
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    // 💡 Key එකට අගයක් නැත්නම්, false return කරයි
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // 2. Onboarding එක දැකලා කියලා Save කරන්න
  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }
}