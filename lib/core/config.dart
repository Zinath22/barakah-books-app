


// class AppConfig {
//   static const String apiBase = String.fromEnvironment(
//     'API',
//     defaultValue: 'http://localhost:5000/api',
//   );
// }


class AppConfig {
  AppConfig._();

  /// USB + adb reverse দিয়ে চালালে localhost-ই ঠিক।
  /// পরে সার্ভার অনলাইনে (Render) তুললে শুধু এই লাইনটা বদলাবেন।
  static const String apiBase = String.fromEnvironment(
    'API',
    defaultValue: 'http://localhost:5000/api',
  );
}