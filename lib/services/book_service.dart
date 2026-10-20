import 'package:dio/dio.dart';
import '../core/config.dart';
import '../models/book.dart';

class BookService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // সব বই (search আর category দিয়ে filter করা যায়)
  static Future<List<Book>> getBooks({String search = '', String category = ''}) async {
    final res = await _dio.get('/products', queryParameters: {
      if (search.isNotEmpty) 'search': search,
      if (category.isNotEmpty) 'category': category,
      'sort': 'newest',
    });
    final list = (res.data['products'] as List?) ?? [];
    return list.map((e) => Book.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}