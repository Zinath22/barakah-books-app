

class AppConfig {
  AppConfig._();

  /// অনলাইন সার্ভার (Render)
  /// পিসির সার্ভারে টেস্ট করতে চাইলে:
  /// flutter run --dart-define=API=http://localhost:5000/api
  static const String apiBase = String.fromEnvironment(
    'API',
    defaultValue: 'https://barakah-books-api.onrender.com/api',
  );
}


// class AppConfig {
//   AppConfig._();

//   /// USB + adb reverse দিয়ে চালালে localhost-ই ঠিক।
//   /// পরে সার্ভার অনলাইনে (Render) তুললে শুধু এই লাইনটা বদলাবেন।
//   static const String apiBase = String.fromEnvironment(
//     'API',
//     defaultValue: 'http://localhost:5000/api',
//   );
// }