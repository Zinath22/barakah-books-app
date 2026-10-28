import '../models/book.dart';
import 'api_client.dart';

class WishlistService {
  WishlistService._();

  /// GET /api/wishlist → উইশলিস্টের বইগুলো
  static Future<List<Book>> get() async {
    final res = await ApiClient.dio.get('/wishlist');
    final list = (res.data['products'] as List?) ?? [];
    return list.map((e) => Book.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// POST /api/wishlist/:id
  static Future<void> add(String bookId) async {
    await ApiClient.dio.post('/wishlist/$bookId');
  }

  /// DELETE /api/wishlist/:id
  static Future<void> remove(String bookId) async {
    await ApiClient.dio.delete('/wishlist/$bookId');
  }
}