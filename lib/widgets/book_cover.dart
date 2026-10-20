import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';

// ছবি থাকলে ছবি দেখায়, না থাকলে (বা ছবি load না হলে) website এর মতো রঙিন প্রচ্ছদ আঁকে
class BookCover extends StatelessWidget {
  final Book book;
  final double fontSize;

  const BookCover({super.key, required this.book, this.fontSize = 13});

  static const _palettes = [
    [0xFF0F5C45, 0xFFF3E3B0, 0xFFC9A227], // সবুজ
    [0xFF1E3A5F, 0xFFF1E2B8, 0xFFD4B25A], // নীল
    [0xFF6B1F2A, 0xFFF4E4C1, 0xFFE0C27A], // মেরুন
    [0xFF115E67, 0xFFF2E6C4, 0xFFE8D49A], // টিল
    [0xFF5A3E2B, 0xFFF5E7C8, 0xFFD9B77E], // বাদামি
    [0xFF3F5A2A, 0xFFF2E7C0, 0xFFE3CF8C], // জলপাই
  ];

  @override
  Widget build(BuildContext context) {
    final drawn = _drawnCover();

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: book.img.isEmpty
            ? drawn
            : CachedNetworkImage(
                imageUrl: book.img,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.black12),
                errorWidget: (_, __, ___) => drawn,
              ),
      ),
    );
  }

  Widget _drawnCover() {
    final p = _palettes[book.title.hashCode.abs() % _palettes.length];
    final ink = Color(p[1]);
    final line = Color(p[2]);

    return Container(
      color: Color(p[0]),
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: line)),
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.star, size: fontSize, color: line),
            Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink, fontWeight: FontWeight.bold, fontSize: fontSize),
            ),
            Text(
              book.author,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: ink, fontSize: fontSize * 0.7),
            ),
          ],
        ),
      ),
    );
  }
}