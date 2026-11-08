import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/utils.dart';
import '../models/book.dart';
import '../providers/auth_state.dart';
import '../providers/cart_provider.dart';
import '../screens/book_detail_screen.dart';
import '../screens/login_screen.dart';
import '../screens/my_orders_screen.dart';
import '../screens/wishlist_screen.dart';
import 'book_cover.dart';
import 'wishlist_button.dart';

/// ওয়েবসাইটের থিমের রং (globals.css থেকে)
class HomeColors {
  static const primary = Color(0xFF0F5C45);
  static const content = Color(0xFFFBF8F1);
  static const gold = Color(0xFFC9A227);
  static const goldContent = Color(0xFF3A2F14);
  static const goldDark = Color(0xFF8A6A0F);
  static const base200 = Color(0xFFFAF6EE); // cream
  static const base300 = Color(0xFFEEE7DA);
  static const text = Color(0xFF1E2B26);
  static const neutral = Color(0xFF1D3A31); // footer
  static const neutralContent = Color(0xFFF6F3EC);
  static const error = Color(0xFFD9433B);
  static const pattern = Color(0xFFD4B25A);
}

TextStyle bn({double? fontSize, FontWeight? fontWeight, Color? color, double? height, TextDecoration? decoration}) =>
    GoogleFonts.hindSiliguri(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );

/// ইংরেজি সংখ্যা → বাংলা সংখ্যা
String bnNum(Object v) =>
    v.toString().replaceAllMapped(RegExp(r'\d'), (m) => '০১২৩৪৫৬৭৮৯'[int.parse(m[0]!)]);

void comingSoon(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text('এই পেজ শীঘ্রই আসছে ইনশাআল্লাহ')));
}

/// লগইন লাগে এমন পেজ খোলা
void openProtected(BuildContext context, Widget page) {
  final loggedIn = context.read<AuthState>().isLoggedIn;
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => loggedIn ? page : const LoginScreen()),
  );
}

void openBook(BuildContext context, Book book) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
}

// =====================================================================
// ২. কুপন অফারের বার
// =====================================================================
class CouponBar extends StatelessWidget {
  final String code;
  final String discountType; // 'percentage' বা অন্য কিছু (টাকা)
  final num discountValue;

  const CouponBar({super.key, required this.code, required this.discountType, required this.discountValue});

  @override
  Widget build(BuildContext context) {
    final off = discountType == 'percentage' ? '${bnNum(discountValue)}%' : '৳ ${bnNum(discountValue)}';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('কুপন কোড "$code" কপি হয়েছে')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: HomeColors.gold, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text('🎁 বিশেষ অফার!', style: bn(fontSize: 15, fontWeight: FontWeight.w700, color: HomeColors.goldContent)),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'কুপন '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      child: Text(code, style: bn(fontSize: 14, fontWeight: FontWeight.w700, color: HomeColors.primary)),
                    ),
                  ),
                  TextSpan(text: ' ব্যবহার করে পান $off ছাড়'),
                ],
              ),
              textAlign: TextAlign.center,
              style: bn(fontSize: 14, color: HomeColors.goldContent),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// ৩. সুবিধা (Features)
// =====================================================================
class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  static const List<(IconData, String, String)> _items = [
    (Icons.local_shipping_outlined, 'সারাদেশে ডেলিভারি', 'ঢাকায় ১–২ দিন, ঢাকার বাইরে ৩–৫ দিন'),
    (Icons.payments_outlined, 'ক্যাশ অন ডেলিভারি', 'বই হাতে পেয়ে টাকা দিন'),
    (Icons.verified_user_outlined, '১০০% অরিজিনাল', 'প্রকাশনী থেকে সরাসরি সংগ্রহ'),
    (Icons.autorenew, 'সহজ বদল', 'ত্রুটিপূর্ণ বই ৭ দিনের মধ্যে বদল'),
  ];

  Widget _card((IconData, String, String) item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeColors.base300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: HomeColors.gold.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(item.$1, size: 20, color: HomeColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.$2, style: bn(fontSize: 14, fontWeight: FontWeight.w600, height: 1.2, color: HomeColors.text)),
                const SizedBox(height: 2),
                Text(item.$3, style: bn(fontSize: 12, height: 1.3, color: HomeColors.text.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(int a, int b) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _card(_items[a])),
            const SizedBox(width: 12),
            Expanded(child: _card(_items[b])),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(children: [_row(0, 1), const SizedBox(height: 12), _row(2, 3)]);
  }
}

// =====================================================================
// বইয়ের কার্ড (ওয়েবসাইটের ProductCard এর মতো)
// =====================================================================
class BookCardMini extends StatelessWidget {
  final Book book;
  final double? width;
  const BookCardMini({super.key, required this.book, this.width});

  @override
  Widget build(BuildContext context) {
    final off = book.discountPercent;
    final inCart = context.watch<CartProvider>().contains(book.id);

    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HomeColors.base300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // প্রচ্ছদ + ব্যাজ
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: BoxDecoration(color: HomeColors.base200, borderRadius: BorderRadius.circular(12)),
                child: GestureDetector(
                  onTap: () => openBook(context, book),
                  child: BookCover(book: book, fontSize: 10),
                ),
              ),
              if (off > 0)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: HomeColors.gold, borderRadius: BorderRadius.circular(20)),
                    child: Text('${bnNum(off)}% ছাড়',
                        style: bn(fontSize: 11, fontWeight: FontWeight.w600, color: HomeColors.goldContent)),
                  ),
                ),
              Positioned(right: -4, top: -4, child: WishlistButton(book: book)),
              if (!book.inStock)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                      decoration: BoxDecoration(color: HomeColors.error, borderRadius: BorderRadius.circular(20)),
                      child: Text('স্টক শেষ', style: bn(fontSize: 11, color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => openBook(context, book),
            child: Text(
              book.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: bn(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3, color: HomeColors.text),
            ),
          ),
          if (book.author.isNotEmpty)
            Text(
              book.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: bn(fontSize: 13, color: HomeColors.text.withValues(alpha: 0.6)),
            ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(taka(book.price), style: bn(fontSize: 17, fontWeight: FontWeight.w700, color: HomeColors.primary)),
              if (off > 0) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    taka(book.originalPrice),
                    overflow: TextOverflow.ellipsis,
                    style: bn(
                      fontSize: 12,
                      color: HomeColors.text.withValues(alpha: 0.4),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: FilledButton.icon(
              onPressed: book.inStock
                  ? () {
                      context.read<CartProvider>().add(book);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          content: Text('"${book.title}" কার্টে যোগ হয়েছে'),
                          duration: const Duration(seconds: 2),
                        ));
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: HomeColors.primary,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: Icon(inCart ? Icons.check : Icons.shopping_cart_outlined, size: 16),
              label: Text(
                !book.inStock ? 'স্টক শেষ' : (inCart ? 'আরেক কপি' : 'কার্টে যোগ'),
                style: bn(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// ৪ ও ৬. বইয়ের সারি (নতুন সংযোজন / বিশেষ ছাড়)
// =====================================================================
class BookShelfRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Book> books;
  final VoidCallback? onSeeAll;

  const BookShelfRow({super.key, required this.title, this.subtitle, required this.books, this.onSeeAll});

  static const double cardHeight = 370;

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: bn(fontSize: 22, fontWeight: FontWeight.w700, color: HomeColors.text)),
                    if (subtitle != null)
                      Text(subtitle!, style: bn(fontSize: 14, color: HomeColors.text.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              TextButton(
                onPressed: onSeeAll ?? () => comingSoon(context),
                child: Text('সব দেখুন →', style: bn(fontSize: 14, fontWeight: FontWeight.w600, color: HomeColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => BookCardMini(book: books[i], width: 176),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// ৫. আজকের আয়াত
// =====================================================================
class DailyAyahCard extends StatelessWidget {
  const DailyAyahCard({super.key});

  static const List<(String, String, String)> _ayahs = [
    ('اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ', 'পড়ো তোমার প্রতিপালকের নামে, যিনি সৃষ্টি করেছেন।', 'সূরা আল-আলাক, ৯৬:১'),
    ('وَقُل رَّبِّ زِدْنِي عِلْمًا', 'আর বলো, হে আমার প্রতিপালক! আমার জ্ঞান বৃদ্ধি করে দাও।', 'সূরা ত্বহা, ২০:১১৪'),
    ('قُلْ هَلْ يَسْتَوِي الَّذِينَ يَعْلَمُونَ وَالَّذِينَ لَا يَعْلَمُونَ', 'বলো, যারা জানে আর যারা জানে না, তারা কি সমান?', 'সূরা আয-যুমার, ৩৯:৯'),
    ('فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', 'নিশ্চয়ই কষ্টের সাথেই রয়েছে স্বস্তি।', 'সূরা আশ-শারহ, ৯৪:৫'),
    ('أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'জেনে রাখো, আল্লাহর স্মরণেই অন্তর প্রশান্ত হয়।', "সূরা আর-রা'দ, ১৩:২৮"),
    ('لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا', 'আল্লাহ কাউকে তার সাধ্যের বাইরে দায়িত্ব দেন না।', 'সূরা আল-বাকারা, ২:২৮৬'),
    (
      'يَرْفَعِ اللَّهُ الَّذِينَ آمَنُوا مِنكُمْ وَالَّذِينَ أُوتُوا الْعِلْمَ دَرَجَاتٍ',
      'তোমাদের মধ্যে যারা ঈমান এনেছে এবং যাদের জ্ঞান দেওয়া হয়েছে, আল্লাহ তাদের মর্যাদা উঁচু করে দেবেন।',
      'সূরা আল-মুজাদালা, ৫৮:১১'
    ),
  ];

  // বাংলাদেশের তারিখ অনুযায়ী প্রতিদিন একটা (ওয়েবসাইটের মতো)
  int _todayIndex() {
    final d = DateTime.now().toUtc().add(const Duration(hours: 6));
    final dayOfYear = d.difference(DateTime.utc(d.year, 1, 1)).inDays + 1;
    return dayOfYear % _ayahs.length;
  }

  @override
  Widget build(BuildContext context) {
    final a = _ayahs[_todayIndex()];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HomeColors.gold.withValues(alpha: 0.4)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, HomeColors.gold.withValues(alpha: 0.1)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HomeColors.gold),
            ),
            child: Text('আজকের আয়াত', style: bn(fontSize: 13, fontWeight: FontWeight.w600, color: HomeColors.goldDark)),
          ),
          const SizedBox(height: 16),
          Text(
            a.$1,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(fontSize: 24, height: 1.9, color: HomeColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            '“${a.$2}”',
            textAlign: TextAlign.center,
            style: bn(fontSize: 17, height: 1.5, color: HomeColors.text.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 6),
          Text('— ${a.$3}', style: bn(fontSize: 13, color: HomeColors.text.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}

// =====================================================================
// ৭. ফুটার
// =====================================================================
class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  static const _categories = [
    'কুরআন ও তাফসীর',
    'হাদিস',
    'সীরাত',
    'ফিকহ ও মাসায়েল',
    'আকীদা',
    'আত্মশুদ্ধি',
    'শিশু-কিশোর',
    'ইতিহাস',
  ];

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t, style: bn(fontSize: 15, fontWeight: FontWeight.w600, color: HomeColors.gold)),
      );

  Widget _link(String t, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(t, style: bn(fontSize: 14, color: HomeColors.neutralContent.withValues(alpha: 0.7))),
        ),
      );

  Widget _contact(IconData icon, String t) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: HomeColors.neutralContent.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
            Text(t, style: bn(fontSize: 14, color: HomeColors.neutralContent.withValues(alpha: 0.7))),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final faded = HomeColors.neutralContent.withValues(alpha: 0.7);

    return Container(
      color: HomeColors.neutral,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: IslamicPatternPainter())),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // লোগো + পরিচয়
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(color: HomeColors.gold, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.menu_book_rounded, color: HomeColors.neutral, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Text('বারাকাহ বুকস',
                            style: bn(fontSize: 20, fontWeight: FontWeight.w700, color: HomeColors.neutralContent)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'বিশুদ্ধ জ্ঞানের আলো ঘরে ঘরে পৌঁছে দেওয়াই আমাদের লক্ষ্য। নির্ভরযোগ্য লেখক ও প্রকাশনীর ইসলামিক বই — সারাদেশে হোম ডেলিভারি।',
                      style: bn(fontSize: 14, height: 1.6, color: faded),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [Icons.facebook, Icons.smart_display, Icons.chat_bubble]
                          .map((ic) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => comingSoon(context),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(ic, size: 18, color: HomeColors.neutralContent),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 32),

                    // ক্যাটাগরি (২ কলাম)
                    _title('ক্যাটাগরি'),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _categories.take(4).map((c) => _link(c, () => comingSoon(context))).toList(),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _categories.skip(4).map((c) => _link(c, () => comingSoon(context))).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // প্রয়োজনীয় লিংক
                    _title('প্রয়োজনীয় লিংক'),
                    _link('সব বই', () => comingSoon(context)),
                    _link('বেস্টসেলার', () => comingSoon(context)),
                    _link('অফার', () => comingSoon(context)),
                    _link('আমার অর্ডার', () => openProtected(context, const MyOrdersScreen())),
                    _link('উইশলিস্ট', () => openProtected(context, const WishlistScreen())),
                    const SizedBox(height: 28),

                    // যোগাযোগ
                    _title('যোগাযোগ'),
                    _contact(Icons.location_on_outlined, 'ঢাকা, বাংলাদেশ'),
                    _contact(Icons.phone_outlined, '০১৭০০-০০০০০০'),
                    _contact(Icons.mail_outline, 'info@barakahbooks.com'),
                    const SizedBox(height: 10),
                    Text('পেমেন্ট', style: bn(fontSize: 12, color: HomeColors.neutralContent.withValues(alpha: 0.5))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ['ক্যাশ অন ডেলিভারি', 'বিকাশ', 'নগদ', 'কার্ড']
                          .map((m) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(m, style: bn(fontSize: 12, color: HomeColors.neutralContent)),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              // কপিরাইট
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                ),
                child: Text(
                  '© ${bnNum(DateTime.now().year)} বারাকাহ বুকস। সর্বস্বত্ব সংরক্ষিত।',
                  textAlign: TextAlign.center,
                  style: bn(fontSize: 12, color: HomeColors.neutralContent.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ওয়েবসাইটের .islamic-pattern (৬০×৬০ টাইল)
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = HomeColors.pattern.withValues(alpha: 0.18);

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

    for (double y = 0; y < size.height; y += 60) {
      for (double x = 0; x < size.width; x += 60) {
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