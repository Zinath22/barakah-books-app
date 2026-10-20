import 'package:flutter/foundation.dart';
import '../models/book.dart';

class CartItem {
  final Book book;
  int qty;
  CartItem(this.book, {this.qty = 1});

  num get total => book.price * qty;
}

// পুরো অ্যাপে কার্টের তথ্য এখানে থাকে
class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get count => _items.values.fold<int>(0, (sum, i) => sum + i.qty);
  num get subtotal => _items.values.fold<num>(0, (sum, i) => sum + i.total);
  bool contains(String bookId) => _items.containsKey(bookId);

  void add(Book book) {
    final item = _items[book.id];
    if (item != null) {
      increase(book.id);
      return;
    }
    _items[book.id] = CartItem(book);
    notifyListeners();
  }

  void increase(String bookId) {
    final item = _items[bookId];
    if (item == null) return;
    // স্টকের চেয়ে বেশি নেওয়া যাবে না
    if (item.book.stock > 0 && item.qty >= item.book.stock) return;
    item.qty++;
    notifyListeners();
  }

  void decrease(String bookId) {
    final item = _items[bookId];
    if (item == null) return;
    if (item.qty > 1) {
      item.qty--;
    } else {
      _items.remove(bookId);
    }
    notifyListeners();
  }

  void remove(String bookId) {
    _items.remove(bookId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}