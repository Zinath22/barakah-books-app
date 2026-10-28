class OrderItem {
  final String title;
  final String img;
  final num price;
  final int qty;

  OrderItem({required this.title, required this.img, required this.price, required this.qty});

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        title: (j['title'] ?? '').toString(),
        img: (j['img'] ?? '').toString(),
        price: num.tryParse('${j['price'] ?? 0}') ?? 0,
        qty: int.tryParse('${j['qty'] ?? 1}') ?? 1,
      );
}

class Order {
  final String id;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String address;
  final String phone;
  final String couponCode;
  final num subtotal;
  final num discountAmount;
  final num total;
  final DateTime? createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.address,
    required this.phone,
    required this.couponCode,
    required this.subtotal,
    required this.discountAmount,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) {
    final customer = Map<String, dynamic>.from((j['customer'] as Map?) ?? {});
    final rawItems = (j['products'] as List?) ?? [];
    num n(Object? v) => num.tryParse('${v ?? 0}') ?? 0;

    return Order(
      id: (j['_id'] ?? '').toString(),
      status: (j['status'] ?? 'Pending').toString(),
      paymentMethod: (j['paymentMethod'] ?? '').toString(),
      paymentStatus: (j['paymentStatus'] ?? '').toString(),
      address: (customer['address'] ?? '').toString(),
      phone: (customer['phone'] ?? '').toString(),
      couponCode: (j['couponCode'] ?? '').toString(),
      subtotal: n(j['subtotal'] ?? j['total']),
      discountAmount: n(j['discountAmount']),
      total: n(j['total'] ?? j['amount']),
      createdAt: DateTime.tryParse('${j['createdAt'] ?? ''}')?.toLocal(),
      items: rawItems.map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }

  // অর্ডার নম্বর হিসেবে id এর শেষ ৬ অক্ষর
  String get shortId => id.length > 6 ? id.substring(id.length - 6).toUpperCase() : id;
}