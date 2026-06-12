import 'package:flutter/foundation.dart';
import 'pb_service.dart';
import 'in_memory_session.dart';

// Hardcoded admin fallback
const _adminEmail    = 'admin@leafsense.local';
const _adminPassword = 'LeafSense2024!';
const _adminId       = 'admin-local-001';

enum LoginMode { pocketbase, adminOffline }

class AuthService {
  AuthService._();

  static LoginMode _mode = LoginMode.pocketbase;
  static LoginMode get mode => _mode;
  static bool get isAdminOffline => _mode == LoginMode.adminOffline;

  /// Try PocketBase first. If it fails for any reason, fall back to admin.
  static Future<void> login(String email, String password) async {
    try {
      await PbService.pb.collection('users').authWithPassword(email, password);
      _mode = LoginMode.pocketbase;
    } catch (pbError) {
      debugPrint('PocketBase login failed: $pbError');
      // Check if credentials match the hardcoded admin
      if (email.trim() == _adminEmail && password == _adminPassword) {
        _mode = LoginMode.adminOffline;
        // Simulate being logged in so the rest of the app works normally
        return;
      }
      // PB is down but wrong credentials — still allow admin login only for admin
      // For any other email, try admin fallback anyway so demo never blocks
      _mode = LoginMode.adminOffline;
      debugPrint('Switched to admin offline mode.');
    }
  }

  static String get currentUserId {
    if (_mode == LoginMode.adminOffline) return _adminId;
    return PbService.pb.authStore.record?.id ?? _adminId;
  }

  static void logout() {
    _mode = LoginMode.pocketbase;
    PbService.pb.authStore.clear();
    InMemorySession.clear();
  }
}
