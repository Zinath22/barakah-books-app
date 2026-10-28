import '../models/review.dart';
import 'api_client.dart';

class ReviewService {
  ReviewService._();

  /// GET /api/reviews?productId=...
  static Future<List<Review>> forBook(String bookId) async {
    final res = await ApiClient.dio.get('/reviews', queryParameters: {'productId': bookId});
    final list = (res.data['reviews'] as List?) ?? [];
    return list.map((e) => Review.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// POST /api/reviews  (লগইন লাগবে)
  static Future<void> add({
    required String bookId,
    required int rating,
    required String comment,
  }) async {
    await ApiClient.dio.post('/reviews', data: {
      'productId': bookId,
      'rating': rating,
      'comment': comment,
    });
  }
}