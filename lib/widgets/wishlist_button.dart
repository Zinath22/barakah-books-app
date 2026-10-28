import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/wishlist_provider.dart';

/// ❤️ বাটন — বইয়ের বিস্তারিত পেজের AppBar-এ বসবে
class WishlistButton extends StatelessWidget {
  final Book book;
  final Color? color;

  const WishlistButton({super.key, required this.book, this.color});

  @override
  Widget build(BuildContext context) {
    final on = context.watch<WishlistProvider>().contains(book.id);
    return IconButton(
      tooltip: on ? 'উইশলিস্ট থেকে সরান' : 'উইশলিস্টে রাখুন',
      icon: Icon(
        on ? Icons.favorite : Icons.favorite_border,
        color: on ? Colors.red : color,
      ),
      onPressed: () async {
        final msg = await context.read<WishlistProvider>().toggle(book);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
      },
    );
  }
}