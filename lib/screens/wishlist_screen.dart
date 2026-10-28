import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/book.dart';
import '../providers/wishlist_provider.dart';
import 'book_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = context.watch<WishlistProvider>();

    Widget body;
    if (!w.loggedIn) {
      body = const _Message(icon: Icons.lock_outline, text: 'উইশলিস্ট দেখতে আগে লগইন করুন');
    } else if (w.loading && w.books.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (w.error != null && w.books.isEmpty) {
      body = _Message(icon: Icons.wifi_off, text: w.error!);
    } else if (w.books.isEmpty) {
      body = const _Message(
        icon: Icons.favorite_border,
        text: 'উইশলিস্ট খালি\nপছন্দের বইয়ের ❤️ চাপলে এখানে জমা হবে',
      );
    } else {
      body = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: w.books.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _WishTile(book: w.books[i]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('উইশলিস্ট (${toBn(w.count)})')),
      body: RefreshIndicator(onRefresh: w.load, child: body),
    );
  }
}

class _WishTile extends StatelessWidget {
  final Book book;
  const _WishTile({required this.book});

  @override
  Widget build(BuildContext context) {
    final String img = book.img ?? '';
    final String author = book.author ?? '';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 84,
                  child: img.isEmpty
                      ? Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.menu_book, color: AppColors.primary),
                        )
                      : CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(Icons.menu_book),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(author, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      taka(book.price),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'সরান',
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () async {
                  final msg = await context.read<WishlistProvider>().toggle(book);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(msg)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    // ListView দিয়ে মোড়ানো যাতে নিচে টেনে refresh করা যায়
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 150),
        Icon(icon, size: 64, color: Colors.grey),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}