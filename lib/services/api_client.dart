import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/config.dart';

/// উইশলিস্ট আর রিভিউয়ের জন্য Dio — প্রতিটা রিকোয়েস্টে Firebase টোকেন যায়
class ApiClient {
  ApiClient._();

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBase,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken();
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

  /// যেকোনো error থেকে বাংলা বার্তা
  static String errorBn(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'সার্ভারে সংযোগ হচ্ছে না';
      }
      if (e.response?.statusCode == 401) return 'আগে লগইন করুন';
      final data = e.response?.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    }
    return 'কিছু একটা সমস্যা হয়েছে, আবার চেষ্টা করুন';
  }
}