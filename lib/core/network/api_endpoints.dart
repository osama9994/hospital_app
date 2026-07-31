import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android emulator maps host machine localhost to 10.0.2.2
      return 'http://10.0.2.2:3000/api';
    }

    // Windows, macOS, Linux, and iOS simulator
    return 'http://localhost:3000/api';
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get profile => '$baseUrl/auth/profile';
}
