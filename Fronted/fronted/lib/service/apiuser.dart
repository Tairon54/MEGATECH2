import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String get rootUrl {
    if (kIsWeb) return 'http://localhost:3000';
    // Celular real por cable USB (adb reverse)
    if (Platform.isAndroid) return 'http://127.0.0.1:3000';
    return 'http://localhost:3000';
  }

  static String get baseUrl => '$rootUrl/auth';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
