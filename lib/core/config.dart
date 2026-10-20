// class AppConfig {
//   // PC-এর বর্তমান IPv4 Address
//   static const String apiBase = 'http://192.168.1.2:5000/api';
// }


class AppConfig {
  static const String apiBase = String.fromEnvironment(
    'API',
    defaultValue: 'http://localhost:5000/api',
  );
}