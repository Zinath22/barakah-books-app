import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../screens/book_detail_screen.dart';
import 'book_cover.dart';

/// ওয়েবসাইটের থিমের রং (globals.css থেকে)
class _C {
  static const primary = Color(0xFF0F5C45);
  static const content = Color(0xFFFBF8F1);
  static const gold = Color(0xFFC9A227);
  static const goldContent = Color(0xFF3A2F14);
  static const pattern = Color(0xFFD4B25A);
  static const base300 = Color(0xFFE6E1D6);
  static const text = Color(0xFF1E2B26);
  static const success = Color(0xFF16A34A);
}

enum HeroType { design, photo, image }

/// একটা স্লাইডের তথ্য — ওয়েবসাইটের SLIDES এর মতো
class HeroSlide {
  final HeroType type;
  final String? arabic; // design: উপরের আরবি লেখা
  final String? kicker; // photo: শিরোনামের উপরের ছোট লেখা
  final String title; // শিরোনাম ১ম অংশ
  final String line2; // শিরোনাম ২য় অংশ
  final String highlight; // রঙিন শব্দ
  final String? text; // design: বিবরণ
  final List<String> points; // photo: ✓ তালিকা
  final String button;
  final String? category; // বাটন চাপলে কোন ক্যাটাগরি
  final List<String> images; // design: ৩টা বইয়ের ছবি (না দিলে ক্যাটাগরির বই)
  final String? photo; // photo: ছবি
  final bool photoContain; // photo: ছবি কাটা না পড়ে পুরোটা দেখাবে
  final String? banner; // image: পুরো ব্যানারের ছবি (asset বা https লিংক)

  const HeroSlide({
    required this.type,
    this.arabic,
    this.kicker,
    this.title = '',
    this.line2 = '',
    this.highlight = '',
    this.text,
    this.points = const [],
    this.button = '',
    this.category,
    this.images = const [],
    this.photo,
    this.photoContain = false,
    this.banner,
  });
}

// ===================================================================
// স্লাইডগুলো — ওয়েবসাইটের Hero.jsx এর SLIDES থেকে হুবহু
// লেখা, বাটন বা ছবি বদলাতে চাইলে শুধু এখানে বদলান
// ===================================================================
const List<HeroSlide> kHeroSlides = [
  HeroSlide(
    type: HeroType.design,
    arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    title: 'জ্ঞানের আলোয়',
    line2: 'আলোকিত হোক',
    highlight: 'জীবন',
    text: 'কুরআন, হাদিস, সীরাত, ফিকহ আর শিশুদের ইসলামিক বই — নির্ভরযোগ্য লেখক ও প্রকাশনীর বাছাই করা সংগ্রহ, আপনার দোরগোড়ায়।',
    button: 'সব বই দেখুন',
    images: ['assets/banner/images1.jpg'],
  ),
  HeroSlide(
    type: HeroType.photo,
    photo: 'assets/banner/cover.jpg',
    kicker: 'আপনার ঘরে আনুন',
    title: 'কুরআনুল',
    highlight: 'কারীম',
    line2: 'অনুবাদ ও তাফসীর সহ',
    points: ['সহজ বাংলা অনুবাদ', 'নির্ভরযোগ্য তাফসীর', 'মজবুত হার্ডকভার বাঁধাই', 'সারাদেশে দ্রুত ডেলিভারি'],
    button: 'কুরআন ও তাফসীর দেখুন',
    category: 'কুরআন ও তাফসীর',
  ),
  HeroSlide(
    type: HeroType.design,
    arabic: 'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ',
    title: 'প্রিয় নবীজির (সা.)',
    line2: 'জীবন থেকে',
    highlight: 'শিখুন',
    text: 'রাসূলুল্লাহ (সা.)-এর জীবন, চরিত্র আর শিক্ষা — সীরাতের সেরা বইগুলো এক জায়গায়।',
    button: 'সীরাতের বই',
    category: 'সীরাত',
  ),
  HeroSlide(
    type: HeroType.design,
    arabic: 'قَالَ رَسُولُ اللَّهِ ﷺ',
    title: 'সহীহ হাদিসের',
    line2: 'নির্ভরযোগ্য',
    highlight: 'সংকলন',
    text: 'বুখারী, মুসলিম থেকে রিয়াদুস সালেহীন — দৈনন্দিন জীবনের জন্য নবীজির (সা.) বাণী।',
    button: 'হাদিসের বই',
    category: 'হাদিস',
  ),
  HeroSlide(
    type: HeroType.photo,
    photo: 'assets/banner/images2.jpg',
    photoContain: true,
    kicker: 'সীমিত সময়ের জন্য',
    title: 'বিশেষ',
    highlight: 'ছাড়',
    line2: 'প্রিয় বইগুলোতে',
    points: ['নির্বাচিত বইয়ে বড় ছাড়', 'ক্যাশ অন ডেলিভারি', 'ত্রুটিপূর্ণ বই বদলের সুবিধা', 'সারাদেশে হোম ডেলিভারি'],
    button: 'অফারের বই দেখুন',
  ),
  // পুরো ব্যানারের ছবি দিতে চাইলে:
  // HeroSlide(type: HeroType.image, banner: 'https://i.ibb.co/.../mobile.jpg'),
];

const List<String> kHeroFallback = [
  'assets/banner/images1.jpg',
  'assets/banner/images2.jpg',
  'assets/banner/cover.jpg',
];

/// ওয়েবসাইটের মতো ব্যানার — হোম পেজের উপরে
class HomeBanner extends StatefulWidget {
  /// design স্লাইডের বইয়ের জন্য (না দিলে ছবিগুলো দেখাবে)
  final List<Book> books;
  final List<HeroSlide> slides;

  /// বাটন চাপলে (পরে সব বই / ক্যাটাগরি পেজ বানালে এখানে যুক্ত হবে)
  final void Function(HeroSlide slide)? onAction;

  const HomeBanner({
    super.key,
    this.books = const [],
    this.slides = kHeroSlides,
    this.onAction,
  });

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  static const _interval = Duration(seconds: 5);
  static const _fade = Duration(milliseconds: 700);

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // হাতে স্লাইড বদলালে সময় আবার শূন্য থেকে গোনা শুরু হয় (ওয়েবসাইটের মতো)
  void _restart() {
    _timer?.cancel();
    _timer = Timer(_interval, () {
      if (!mounted) return;
      _go(_index + 1);
    });
  }

  void _go(int i) {
    final n = widget.slides.length;
    if (n == 0) return;
    setState(() {
      _index = ((i % n) + n) % n;
    });
    _restart();
  }

  void _action(HeroSlide s) {
    if (widget.onAction != null) {
      widget.onAction!(s);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই পেজ শীঘ্রই আসছে ইনশাআল্লাহ')),
      );
    }
  }

  bool _hasImg(Book b) => (b.img ?? '').isNotEmpty;

  // design স্লাইডের ৩টা বই (ওয়েবসাইটের pickBooks এর মতো)
  List<_CoverItem> _pickCovers(HeroSlide s) {
    if (s.images.isNotEmpty) {
      return List.generate(3, (i) => _CoverItem(asset: s.images[i < s.images.length ? i : 0]));
    }
    List<Book> withImg(Iterable<Book> l) {
      final list = l.toList();
      list.sort((a, b) => (_hasImg(b) ? 1 : 0) - (_hasImg(a) ? 1 : 0));
      return list;
    }

    final books = widget.books;
    var list = s.category != null ? withImg(books.where((b) => b.category == s.category)) : <Book>[];
    if (list.length < 3) {
      list = [...list, ...withImg(books.where((b) => !list.contains(b)))];
    }
    list = list.take(3).toList();
    return List.generate(
      3,
      (i) => i < list.length ? _CoverItem(book: list[i]) : _CoverItem(asset: kHeroFallback[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides;

    return Column(
      children: [
        GestureDetector(
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v > 200) _go(_index - 1);
            if (v < -200) _go(_index + 1);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _C.base300),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(23),
              // সব স্লাইড একই জায়গায়, শুধু চালুটা দেখা যায় — উচ্চতা সবচেয়ে লম্বা স্লাইডের সমান
              child: IntrinsicHeight(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    for (var i = 0; i < slides.length; i++)
                      IgnorePointer(
                        ignoring: i != _index,
                        child: AnimatedOpacity(
                          opacity: i == _index ? 1 : 0,
                          duration: _fade,
                          child: _slide(slides[i], i == _index),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // নিচের ডট
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (i) {
            final active = i == _index;
            return GestureDetector(
              onTap: () => _go(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? _C.primary : _C.text.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _slide(HeroSlide s, bool active) {
    switch (s.type) {
      case HeroType.photo:
        return _photoSlide(s, active);
      case HeroType.image:
        return _imageSlide(s);
      case HeroType.design:
        return _designSlide(s, active);
    }
  }

  // ===== ধরন ১: সবুজ ইসলামিক নকশা =====
  Widget _designSlide(HeroSlide s, bool active) {
    final bn = GoogleFonts.hindSiliguri;
    final covers = _pickCovers(s);

    return Container(
      color: _C.primary,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _IslamicPatternPainter())),
          Positioned(
            right: -96,
            top: -96,
            child: Container(
              width: 288,
              height: 288,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_C.gold.withValues(alpha: 0.28), _C.gold.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSlide(
                  offset: active ? Offset.zero : const Offset(0, 0.04),
                  duration: _fade,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (s.arabic != null)
                        Text(
                          s.arabic!,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(fontSize: 24, color: _C.gold),
                        ),
                      const SizedBox(height: 14),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: '${s.title}\n${s.line2} '),
                            TextSpan(text: s.highlight, style: const TextStyle(color: _C.gold)),
                          ],
                        ),
                        style: bn(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25, color: _C.content),
                      ),
                      if (s.text != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          s.text!,
                          style: bn(fontSize: 15, height: 1.55, color: _C.content.withValues(alpha: 0.8)),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: () => _action(s),
                        style: FilledButton.styleFrom(
                          backgroundColor: _C.gold,
                          foregroundColor: _C.goldContent,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.button, style: bn(fontSize: 15, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // ৩টা হেলানো বই
                Center(
                  child: AnimatedScale(
                    scale: active ? 1 : 0.95,
                    duration: _fade,
                    child: AnimatedOpacity(
                      opacity: active ? 1 : 0,
                      duration: _fade,
                      child: _BookStack(covers: covers),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== ধরন ২: উপরে ছবি, নিচে লেখা =====
  Widget _photoSlide(HeroSlide s, bool active) {
    final bn = GoogleFonts.hindSiliguri;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 224,
            child: ClipRect(
              child: Container(
                color: Colors.white,
                padding: s.photoContain ? const EdgeInsets.all(24) : EdgeInsets.zero,
                child: AnimatedScale(
                  scale: active ? 1.05 : 1.0,
                  duration: const Duration(seconds: 6),
                  curve: Curves.easeOut,
                  child: _img(s.photo ?? kHeroFallback[2], s.photoContain ? BoxFit.contain : BoxFit.cover),
                ),
              ),
            ),
          ),
          Container(height: 1, color: _C.base300),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
            child: AnimatedSlide(
              offset: active ? Offset.zero : const Offset(0, 0.04),
              duration: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (s.kicker != null)
                    Text(s.kicker!, style: bn(fontSize: 18, color: _C.text.withValues(alpha: 0.7))),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${s.title} '),
                        TextSpan(text: s.highlight, style: const TextStyle(color: _C.primary)),
                      ],
                    ),
                    style: bn(fontSize: 36, fontWeight: FontWeight.w700, height: 1.1, color: _C.text),
                  ),
                  if (s.line2.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      s.line2,
                      style: bn(fontSize: 20, fontWeight: FontWeight.w500, color: _C.text.withValues(alpha: 0.8)),
                    ),
                  ],
                  if (s.points.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: _C.base300),
                          bottom: BorderSide(color: _C.base300),
                        ),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < s.points.length; i++)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: i == 0
                                  ? null
                                  : const BoxDecoration(border: Border(top: BorderSide(color: _C.base300))),
                              child: Row(
                                children: [
                                  Expanded(child: Text(s.points[i], style: bn(fontSize: 16, color: _C.text))),
                                  const Icon(Icons.check_circle_outline, color: _C.success, size: 22),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: () => _action(s),
                    style: FilledButton.styleFrom(
                      backgroundColor: _C.primary,
                      foregroundColor: _C.content,
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.button, style: bn(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== ধরন ৩: পুরো ব্যানারের ছবি =====
  Widget _imageSlide(HeroSlide s) {
    return GestureDetector(
      onTap: () => _action(s),
      child: Container(
        color: _C.base300,
        child: _img(s.banner ?? kHeroFallback[0], BoxFit.cover),
      ),
    );
  }

  Widget _img(String src, BoxFit fit) {
    Widget fallback(BuildContext _, Object __, StackTrace? ___) => Container(
          color: _C.primary.withValues(alpha: 0.08),
          child: const Center(child: Icon(Icons.menu_book_rounded, size: 48, color: _C.primary)),
        );
    return src.startsWith('http')
        ? Image.network(src, fit: fit, width: double.infinity, height: double.infinity, errorBuilder: fallback)
        : Image.asset(src, fit: fit, width: double.infinity, height: double.infinity, errorBuilder: fallback);
  }
}

class _CoverItem {
  final String? asset;
  final Book? book;
  const _CoverItem({this.asset, this.book});
}

/// ৩টা হেলানো বই (ওয়েবসাইটের মোবাইল মাপে)
class _BookStack extends StatelessWidget {
  final List<_CoverItem> covers;
  const _BookStack({required this.covers});

  Widget _cover(BuildContext context, _CoverItem c) {
    final Widget inner = c.book != null
        ? BookCover(book: c.book!, fontSize: 11)
        : AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              child: Image.asset(
                c.asset!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF1C5644)),
              ),
            ),
          );

    return GestureDetector(
      onTap: c.book == null
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailScreen(book: c.book!)),
              ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(4, 6)),
          ],
        ),
        child: inner,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const deg = math.pi / 180;
    return SizedBox(
      width: 224,
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // নিচের ছায়া
          Positioned(
            left: 16,
            right: 16,
            bottom: 4,
            height: 14,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12)],
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 32,
            width: 112,
            child: Transform.rotate(angle: -12 * deg, child: _cover(context, covers[1])),
          ),
          Positioned(
            right: 0,
            top: 32,
            width: 112,
            child: Transform.rotate(angle: 12 * deg, child: _cover(context, covers[2])),
          ),
          Positioned(
            left: 48,
            top: 0,
            width: 128,
            child: _cover(context, covers[0]),
          ),
        ],
      ),
    );
  }
}

/// ওয়েবসাইটের .islamic-pattern এর হুবহু নকশা (৬০×৬০ টাইল)
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _C.pattern.withValues(alpha: 0.18);

    final star = Path()
      ..moveTo(30, 6)
      ..lineTo(37, 23)
      ..lineTo(54, 30)
      ..lineTo(37, 37)
      ..lineTo(30, 54)
      ..lineTo(23, 37)
      ..lineTo(6, 30)
      ..lineTo(23, 23)
      ..close();

    final diamond = Path()
      ..moveTo(30, 14.44)
      ..lineTo(45.56, 30)
      ..lineTo(30, 45.56)
      ..lineTo(14.44, 30)
      ..close();

    const tile = 60.0;
    for (double y = 0; y < size.height; y += tile) {
      for (double x = 0; x < size.width; x += tile) {
        canvas.save();
        canvas.translate(x, y);
        canvas.drawPath(star, paint);
        canvas.drawPath(diamond, paint);
        canvas.drawCircle(const Offset(30, 30), 4, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}