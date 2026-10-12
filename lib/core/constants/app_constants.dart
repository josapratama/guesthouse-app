class AppConstants {
  AppConstants._();

  static const String appName = 'Guest House App';
  static const String appVersion = '1.0.0';

  // API — PostgREST berjalan di Docker
  // Android emulator gunakan 10.0.2.2 untuk akses localhost host machine
  static const String baseUrl = 'http://10.0.2.2:3001';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';

  // Pagination
  static const int defaultPageSize = 20;
}
