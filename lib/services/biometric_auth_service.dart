import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();

  factory BiometricAuthService() {
    return _instance;
  }

  static BiometricAuthService get instance => _instance;

  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _fingerprintKey = 'fingerprint';
  static const String _faceIdKey = 'face_id';

  /// Check if device supports biometrics
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('Biometric check failed: $e');
      return false;
    }
  }

  /// Get list of available biometrics
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Getting available biometrics failed: $e');
      return [];
    }
  }

  /// Check if device has facial recognition
  Future<bool> hasFaceID() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Check if device has fingerprint unlock
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
          useErrorDialogs: useErrorDialogs,
        ),
      );

      return isAuthenticated;
    } catch (e) {
      print('Authentication failed: $e');
      return false;
    }
  }

  /// Enable biometric login
  Future<void> enableBiometricLogin(String email) async {
    try {
      await _secureStorage.write(
        key: _biometricEnabledKey,
        value: 'true',
      );
      await _secureStorage.write(
        key: _fingerprintKey,
        value: email,
      );
      print('Biometric login enabled for: $email');
    } catch (e) {
      print('Failed to enable biometric login: $e');
    }
  }

  /// Disable biometric login
  Future<void> disableBiometricLogin() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _fingerprintKey);
      await _secureStorage.delete(key: _faceIdKey);
      print('Biometric login disabled');
    } catch (e) {
      print('Failed to disable biometric login: $e');
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get stored email for biometric login
  Future<String?> getStoredEmail() async {
    try {
      return await _secureStorage.read(key: _fingerprintKey);
    } catch (e) {
      return null;
    }
  }

  /// Perform biometric login
  Future<String?> biometricLogin() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return null;

      final canAuth = await canCheckBiometrics();
      if (!canAuth) return null;

      final isAuthenticated = await authenticate(
        reason: 'Authenticate to login with biometric',
      );

      if (isAuthenticated) {
        return await getStoredEmail();
      }

      return null;
    } catch (e) {
      print('Biometric login failed: $e');
      return null;
    }
  }

  /// Get biometric type name
  String getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }
}
