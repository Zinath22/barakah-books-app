import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config.dart';

// Server এ প্রতিটা request এর সাথে login token নিজে থেকে যোগ হয়
class Api {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
}