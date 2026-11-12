import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // false = backend local, true = backend en Render
  static const bool useRemote = true;
  static const String _remoteUrl = 'https://megatech2.onrender.com';

  // true = celular real por USB (adb reverse), false = emulador
  static const bool esCelularReal = false;

  static String get rootUrl {
    if (useRemote) return _remoteUrl;
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) {
      return esCelularReal
          ? 'http://127.0.0.1:3000' // celular real + adb reverse
          : 'http://10.0.2.2:3000'; // emulador Android
    }
    return 'http://localhost:3000'; // iOS simulator / escritorio
  }

  static String get baseUrl => '$rootUrl/auth';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
