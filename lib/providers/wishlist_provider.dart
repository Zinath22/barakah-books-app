import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/api_client.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider() {
    // লগইন হলে উইশলিস্ট আনবে, লগআউট হলে খালি করবে
    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _books = [];
        _ids.clear();
        error = null;
        notifyListeners();
      } else {
        load();
      }
    });
  }

  StreamSubscription<User?>? _sub;
  List<Book> _books = [];
  final Set<String> _ids = {};
  bool loading = false;
  String? error;

  List<Book> get books => List.unmodifiable(_books);
  int get count => _ids.length;
  bool contains(String bookId) => _ids.contains(bookId);
  bool get loggedIn => FirebaseAuth.instance.currentUser != null;

  Future<void> load() async {
    if (!loggedIn) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      _books = await WishlistService.get();
      _ids
        ..clear()
        ..addAll(_books.map((b) => b.id));
    } catch (e) {
      error = ApiClient.errorBn(e);
    }
    loading = false;
    notifyListeners();
  }

  /// ❤️ চাপলে যোগ/বাদ। ফেরত দেয় দেখানোর মতো বার্তা।
  Future<String> toggle(Book book) async {
    if (!loggedIn) return 'উইশলিস্টে রাখতে আগে লগইন করুন';

    final had = _ids.contains(book.id);
    _apply(book, add: !had); // সাথে সাথে UI বদলাবে

    try {
      if (had) {
        await WishlistService.remove(book.id);
        return 'উইশলিস্ট থেকে সরানো হয়েছে';
      } else {
        await WishlistService.add(book.id);
        return 'উইশলিস্টে যোগ হয়েছে ❤️';
      }
    } catch (e) {
      _apply(book, add: had); // ব্যর্থ হলে আগের অবস্থায় ফেরত
      return ApiClient.errorBn(e);
    }
  }

  void _apply(Book book, {required bool add}) {
    if (add) {
      _ids.add(book.id);
      _books.removeWhere((b) => b.id == book.id);
      _books.insert(0, book);
    } else {
      _ids.remove(book.id);
      _books.removeWhere((b) => b.id == book.id);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}