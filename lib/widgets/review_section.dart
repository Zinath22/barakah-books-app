import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/review.dart';
import '../services/api_client.dart';
import '../services/review_service.dart';

/// ইংরেজি সংখ্যা → বাংলা সংখ্যা (যেমন 4.5 → ৪.৫)
String _bnDigits(String s) =>
    s.split('').map((c) => '0123456789'.contains(c) ? '০১২৩৪৫৬৭৮৯'['0123456789'.indexOf(c)] : c).join();

/// বইয়ের বিস্তারিত পেজের নিচে রিভিউ অংশ
class ReviewSection extends StatefulWidget {
  final String bookId;
  const ReviewSection({super.key, required this.bookId});

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  late Future<List<Review>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReviewService.forBook(widget.bookId);
  }

  void _reload() {
    setState(() {
      _future = ReviewService.forBook(widget.bookId);
    });
  }

  Widget _stars(int n, {double size = 16}) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (i) => Icon(
            i < n ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: AppColors.gold,
          ),
        ),
      );

  Future<void> _openWriteDialog() async {
    if (FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('রিভিউ লিখতে আগে লগইন করুন')),
      );
      return;
    }

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _WriteReviewSheet(bookId: widget.bookId),
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('জাযাকাল্লাহু খাইরান! আপনার রিভিউ যোগ হয়েছে')),
      );
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _future,
      builder: (context, snap) {
        final reviews = snap.data ?? [];
        final avg = reviews.isEmpty
            ? 0.0
            : reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 32),
            Row(
              children: [
                Text(
                  'পাঠকদের রিভিউ (${toBn(reviews.length)})',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _openWriteDialog,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('রিভিউ লিখুন'),
                ),
              ],
            ),
            if (reviews.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      _bnDigits(avg.toStringAsFixed(1)),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    _stars(avg.round(), size: 20),
                  ],
                ),
              ),
            if (snap.connectionState != ConnectionState.done)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snap.hasError)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Text(ApiClient.errorBn(snap.error!))),
                    TextButton(onPressed: _reload, child: const Text('আবার চেষ্টা')),
                  ],
                ),
              )
            else if (reviews.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'এখনো কোনো রিভিউ নেই। প্রথম রিভিউটি আপনিই লিখুন!',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              ...reviews.map(
                (r) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                        backgroundImage: r.userImage != null ? NetworkImage(r.userImage!) : null,
                        child: r.userImage == null
                            ? Text(
                                r.userName.characters.first.toUpperCase(),
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.userName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  dateBn(r.createdAt),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            _stars(r.rating, size: 14),
                            if (r.comment.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(r.comment),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// রিভিউ লেখার নিচের শিট
class _WriteReviewSheet extends StatefulWidget {
  final String bookId;
  const _WriteReviewSheet({required this.bookId});

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 5;
  final _comment = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await ReviewService.add(
        bookId: widget.bookId,
        rating: _rating,
        comment: _comment.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _sending = false;
        _error = ApiClient.errorBn(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('আপনার রিভিউ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => IconButton(
                onPressed: _sending
                    ? null
                    : () {
                        setState(() {
                          _rating = i + 1;
                        });
                      },
                icon: Icon(
                  i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 36,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _comment,
            maxLines: 4,
            maxLength: 500,
            enabled: !_sending,
            decoration: InputDecoration(
              hintText: 'বইটি কেমন লাগলো? (ঐচ্ছিক)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('রিভিউ জমা দিন'),
            ),
          ),
        ],
      ),
    );
  }
}