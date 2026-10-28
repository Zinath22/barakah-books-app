import 'package:dio/dio.dart';

// Server এর error এর বার্তা সহজ বাংলায় দেখানোর জন্য
class AppError implements Exception {
  final String message;
  AppError(this.message);

  @override
  String toString() => message;

  factory AppError.from(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return AppError(data['message'].toString());
      }
      return AppError('Server এ পৌঁছানো যায়নি। Server চালু আছে কিনা দেখুন');
    }
    return AppError(e.toString());
  }
}