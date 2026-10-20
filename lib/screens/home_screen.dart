import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/book_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _category = ''; // '' মানে সব বই
  String _search = '';
  late Future<List<Book>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = BookService.getBooks(search: _search, category: _category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বারাকাহ বুকস', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: CustomScrollView(
          slivers: [
            // Search box
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'বই, লেখক বা প্রকাশনী খুঁজুন',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (v) {
                    _search = v.trim();
                    _load();
                  },
                ),
              ),
            ),

            // ক্যাটাগরি
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: ['', ...categories].map((c) {
                    final selected = _category == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.isEmpty ? 'সব বই' : c),
                        selected: selected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
                        onSelected: (_) {
                          _category = c;
                          _load();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // বইয়ের তালিকা
            FutureBuilder<List<Book>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('Server এ connect করা যাচ্ছে না',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text(
                            'Server চালু আছে কিনা, আর config.dart এর IP ঠিক আছে কিনা দেখুন',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(onPressed: _load, child: const Text('আবার চেষ্টা করুন')),
                        ],
                      ),
                    ),
                  );
                }
                final books = snap.data ?? [];
                if (books.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('কোনো বই পাওয়া যায়নি')),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.52,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => BookCard(book: books[i]),
                      childCount: books.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}