import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // false = emular local, true = usar el backend en Render
  static const bool useRemote = true;
  static const String _remoteUrl = 'https://megatech2.onrender.com';

  static String get rootUrl {
    if (useRemote) return _remoteUrl;
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
