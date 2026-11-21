import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';

/// Service managing device biometric authentication (Face ID / Touch ID / Passcode).
class SecurityService {
  final LocalAuthentication _auth;
  final SharedPreferences prefs;

  SecurityService({
    LocalAuthentication? auth,
    required this.prefs,
  }) : _auth = auth ?? LocalAuthentication();

  bool get isBiometricEnabled =>
      prefs.getBool(StorageKeys.isBiometricLockEnabled) ?? false;

  Future<bool> setBiometricEnabled(bool enabled) async {
    return await prefs.setBool(StorageKeys.isBiometricLockEnabled, enabled);
  }

  /// Checks if the device has biometric hardware and enrolled biometrics or passcode.
  Future<bool> canAuthenticate() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Returns available biometric types (e.g. Face ID, fingerprint).
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Prompts the user with the native iOS Face ID / Touch ID dialog.
  Future<bool> authenticate({
    String reason = 'Unlock Thovario to access your private thoughts',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    }
  }
}
