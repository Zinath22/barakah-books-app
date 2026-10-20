import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/book.dart';
import '../widgets/book_cover.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final off = book.discountPercent;
    final specs = <List<String>>[
      ['লেখক', book.author],
      ['অনুবাদক', book.translator],
      ['প্রকাশনী', book.publisher],
      ['ক্যাটাগরি', book.category],
      ['পৃষ্ঠা', book.pages > 0 ? toBn(book.pages) : ''],
      ['ভাষা', book.language],
      ['বাঁধাই', book.binding],
    ].where((s) => s[1].isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(title: Text(book.title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: SizedBox(width: 200, child: BookCover(book: book, fontSize: 20))),
          const SizedBox(height: 20),
          Text(book.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('লেখক: ${book.author}', style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 14),

          // দাম
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Text(taka(book.price),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                if (off > 0) ...[
                  const SizedBox(width: 8),
                  Text(taka(book.originalPrice),
                      style: const TextStyle(
                          color: Colors.grey, decoration: TextDecoration.lineThrough)),
                  const SizedBox(width: 8),
                  Text('${toBn(off)}% ছাড়',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
                ],
                const Spacer(),
                Text(book.inStock ? 'স্টকে আছে' : 'স্টক শেষ',
                    style: TextStyle(color: book.inStock ? Colors.green : Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 14),

                    Builder(builder: (context) {
            final inCart = context.watch<CartProvider>().contains(book.id);
            return FilledButton.icon(
              onPressed: book.inStock
                  ? () {
                      context.read<CartProvider>().add(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('"${book.title}" কার্টে যোগ হয়েছে'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              icon: Icon(inCart ? Icons.check : Icons.shopping_cart_outlined),
              label: Text(!book.inStock
                  ? 'স্টক শেষ'
                  : inCart
                      ? 'আরেক কপি যোগ করুন'
                      : 'কার্টে যোগ করুন'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            );
          }),
          const SizedBox(height: 20),

          // বইয়ের তথ্য
          if (specs.isNotEmpty)
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: specs
                    .map((s) => ListTile(
                          dense: true,
                          title: Text(s[0], style: TextStyle(color: Colors.grey.shade600)),
                          trailing: Text(s[1]),
                        ))
                    .toList(),
              ),
            ),

          if (book.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('বই সম্পর্কে', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(book.description, style: const TextStyle(height: 1.6)),
          ],
        ],
      ),
    );
  }
}