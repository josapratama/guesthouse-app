class AppConstants {
  AppConstants._();

  static const String appName = 'Guest House App';
  static const String appVersion = '1.0.0';

  // API — PostgREST berjalan di Docker
  // - Android Emulator (AVD): gunakan 10.0.2.2
  // - HP Fisik: gunakan IP komputer di jaringan lokal (cek dengan ipconfig)
  static const String baseUrl = 'http://192.168.100.11:3001';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';

  // Pagination
  static const int defaultPageSize = 20;
}
