import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_client.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_sections.dart';

class _Coupon {
  final String code;
  final String discountType;
  final num discountValue;
  const _Coupon(this.code, this.discountType, this.discountValue);
}

class _HomeData {
  final List<Book> all; // নতুন থেকে পুরোনো
  final List<Book> popular; // বেশি বিক্রি
  final _Coupon? coupon;
  const _HomeData(this.all, this.popular, this.coupon);
}

const String _allLabel = 'সব বই';
const List<String> _categories = [
  _allLabel,
  'কুরআন ও তাফসীর',
  'হাদিস',
  'সীরাত',
  'ফিকহ ও মাসায়েল',
  'আকীদা',
  'আত্মশুদ্ধি',
  'শিশু-কিশোর',
  'ইতিহাস',
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeData> _future;
  final _search = TextEditingController();
  final _scroll = ScrollController();

  String _query = '';
  String _category = _allLabel;

  bool get _filtering => _query.isNotEmpty || _category != _allLabel;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---------------- ডেটা আনা ----------------
  List<Book> _parse(dynamic data) {
    final list = (data is Map ? data['products'] as List? : null) ?? [];
    return list.map((e) => Book.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<_Coupon?> _loadCoupon() async {
    try {
      final res = await ApiClient.dio.get('/coupons/active');
      final c = res.data['coupon'];
      if (c == null) return null;
      return _Coupon(
        (c['code'] ?? '').toString(),
        (c['discountType'] ?? '').toString(),
        (c['discountValue'] as num?) ?? 0,
      );
    } catch (_) {
      return null; // কুপন না এলেও হোম পেজ চলবে
    }
  }

  Future<_HomeData> _load() async {
    final couponFuture = _loadCoupon();
    final results = await Future.wait([
      ApiClient.dio.get('/products', queryParameters: {'sort': 'newest'}),
      ApiClient.dio.get('/products', queryParameters: {'sort': 'popular', 'limit': 10}),
    ]);
    return _HomeData(_parse(results[0].data), _parse(results[1].data), await couponFuture);
  }

  Future<void> _refresh() async {
    final f = _load();
    setState(() {
      _future = f;
    });
    try {
      await f;
    } catch (_) {}
  }

  // ---------------- খোঁজা আর ক্যাটাগরি ----------------
  List<Book> _filter(List<Book> all) {
    final q = _query.toLowerCase();
    return all.where((b) {
      final catOk = _category == _allLabel || b.category == _category;
      if (!catOk) return false;
      if (q.isEmpty) return true;
      return b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.publisher.toLowerCase().contains(q) ||
          b.translator.toLowerCase().contains(q);
    }).toList();
  }

  void _selectCategory(String c) {
    setState(() {
      _category = c;
    });
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _clearSearch() {
    _search.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _query = '';
    });
  }

  // ---------------- ওপরের সার্চ বার ----------------
  Widget _searchBar() {
    return TextField(
      controller: _search,
      textInputAction: TextInputAction.search,
      onChanged: (v) {
        setState(() {
          _query = v.trim();
        });
      },
      style: bn(fontSize: 16, color: HomeColors.text),
      decoration: InputDecoration(
        hintText: 'বই, লেখক বা প্রকাশনী খুঁজুন',
        hintStyle: bn(fontSize: 16, color: HomeColors.text.withValues(alpha: 0.5)),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close), onPressed: _clearSearch),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
      ),
    );
  }

  // ---------------- ক্যাটাগরির চিপ ----------------
  Widget _categoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = _categories[i];
          final selected = c == _category;
          return ChoiceChip(
            label: Text(c),
            selected: selected,
            onSelected: (_) => _selectCategory(c),
            showCheckmark: true,
            checkmarkColor: Colors.white,
            selectedColor: HomeColors.primary,
            backgroundColor: HomeColors.primary.withValues(alpha: 0.06),
            side: BorderSide(color: selected ? HomeColors.primary : HomeColors.primary.withValues(alpha: 0.25)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            labelStyle: bn(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : HomeColors.text,
            ),
          );
        },
      ),
    );
  }

  // ---------------- বইয়ের গ্রিড ----------------
  Widget _grid(List<Book> books) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => BookCardMini(book: books[i]),
          childCount: books.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: BookShelfRow.cardHeight,
        ),
      ),
    );
  }

  Widget _title(String t) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(t, style: bn(fontSize: 20, fontWeight: FontWeight.w700, color: HomeColors.text)),
        ),
      );

  // ---------------- খোঁজা বা ক্যাটাগরি চালু থাকলে ----------------
  List<Widget> _resultSlivers(List<Book> all) {
    final found = _filter(all);
    final heading = _query.isNotEmpty
        ? '"$_query" এর ফলাফল (${bnNum(found.length)})'
        : '$_category (${bnNum(found.length)})';

    return [
      _title(heading),
      if (found.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.search_off, size: 56, color: Colors.grey),
                const SizedBox(height: 8),
                Text('কোনো বই পাওয়া যায়নি', style: bn(fontSize: 16, color: HomeColors.text)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    _clearSearch();
                    _selectCategory(_allLabel);
                  },
                  child: const Text('সব বই দেখুন'),
                ),
              ],
            ),
          ),
        )
      else
        _grid(found),
    ];
  }

  // ---------------- সাধারণ হোম (ওয়েবসাইটের মতো) ----------------
  List<Widget> _homeSlivers(_HomeData d) {
    final newest = d.all.take(10).toList();
    final offers = d.all.where((b) => b.discountPercent >= 20).take(5).toList();
    final heroBooks = d.popular.length >= 3 ? d.popular : newest;

    return [
      // ১. ব্যানার
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: HomeBanner(
            books: heroBooks,
            onAction: (s) {
              if (s.category != null) {
                _selectCategory(s.category!);
              } else {
                comingSoon(context);
              }
            },
          ),
        ),
      ),

      // ২. কুপন বার
      if (d.coupon != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: CouponBar(
              code: d.coupon!.code,
              discountType: d.coupon!.discountType,
              discountValue: d.coupon!.discountValue,
            ),
          ),
        ),

      // ৩. সুবিধা
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: FeaturesGrid(),
        ),
      ),

      // ৪. নতুন সংযোজন
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 32),
          child: BookShelfRow(title: 'নতুন সংযোজন', subtitle: 'সদ্য আসা বইগুলো', books: newest),
        ),
      ),

      // ৫. আজকের আয়াত
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
          child: DailyAyahCard(),
        ),
      ),

      // ৬. বিশেষ ছাড়
      if (offers.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 32),
            child: BookShelfRow(title: 'বিশেষ ছাড়', subtitle: '২০% বা তার বেশি ছাড়ে', books: offers),
          ),
        ),

      // সব বই
      if (d.all.isNotEmpty) ...[
        _title('সব বই'),
        _grid(d.all),
      ] else
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              children: [
                Text('📚', style: TextStyle(fontSize: 40)),
                SizedBox(height: 8),
                Text('এখনো কোনো বই যোগ করা হয়নি'),
              ],
            ),
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.base200,
      appBar: AppBar(title: const Text('বারাকাহ বুকস')),
      body: FutureBuilder<_HomeData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return ListView(
              children: [
                const SizedBox(height: 140),
                const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Center(child: Text(ApiClient.errorBn(snap.error!), textAlign: TextAlign.center)),
                const SizedBox(height: 12),
                Center(child: FilledButton(onPressed: _refresh, child: const Text('আবার চেষ্টা করুন'))),
              ],
            );
          }

          final d = snap.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                // 🔍 সার্চ বার (আগের মতো)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: _searchBar(),
                  ),
                ),

                // 🏷️ ক্যাটাগরির চিপ (আগের মতো)
                SliverToBoxAdapter(child: _categoryChips()),

                // খুঁজলে বা ক্যাটাগরি বাছলে শুধু ফলাফল, নইলে পুরো হোম
                ...(_filtering ? _resultSlivers(d.all) : _homeSlivers(d)),

                // ৭. ফুটার
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: HomeFooter(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}