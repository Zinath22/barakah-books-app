import '../core/api.dart';
import '../core/errors.dart';
import '../models/order.dart';
import '../providers/cart_provider.dart';

class OrderService {
  // কুপন যাচাই: ঠিক থাকলে ছাড়ের পরিমাণ ফেরত দেয়
  static Future<Map<String, dynamic>> validateCoupon(String code, num amount) async {
    try {
      final res = await Api.dio.post('/coupons/validate', data: {
        'code': code,
        'orderAmount': amount,
      });
      return Map<String, dynamic>.from(res.data);
    } catch (e) {
      throw AppError.from(e);
    }
  }

  // Cash on Delivery অর্ডার (দাম server নিজেই database থেকে হিসাব করে)
  static Future<Order> placeCodOrder({
    required List<CartItem> items,
    required String name,
    required String phone,
    required String address,
    required String city,
    String? couponCode,
  }) async {
    try {
      final res = await Api.dio.post('/orders', data: {
        'items': items.map((i) => {'productId': i.book.id, 'qty': i.qty}).toList(),
        'name': name,
        'phone': phone,
        'address': address,
        'city': city,
        if (couponCode != null && couponCode.isNotEmpty) 'couponCode': couponCode,
      });
      return Order.fromJson(Map<String, dynamic>.from(res.data['order']));
    } catch (e) {
      throw AppError.from(e);
    }
  }

  static Future<List<Order>> myOrders() async {
    try {
      final res = await Api.dio.get('/orders/my');
      final list = (res.data['orders'] as List?) ?? [];
      return list.map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      throw AppError.from(e);
    }
  }

  static Future<void> cancel(String orderId) async {
    try {
      await Api.dio.patch('/orders/$orderId/cancel');
    } catch (e) {
      throw AppError.from(e);
    }
  }
}