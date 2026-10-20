class Book {
  final String id;
  final String title;
  final String author;
  final String translator;
  final String publisher;
  final String category;
  final String language;
  final String binding;
  final String img;
  final String description;
  final num price;
  final num originalPrice;
  final int pages;
  final int stock; // -1 মানে স্টক দেওয়া নেই (সবসময় পাওয়া যাবে)

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.translator,
    required this.publisher,
    required this.category,
    required this.language,
    required this.binding,
    required this.img,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.pages,
    required this.stock,
  });

  // MongoDB থেকে আসা JSON কে Book এ বদলানো
  factory Book.fromJson(Map<String, dynamic> j) {
    String s(String key) => (j[key] ?? '').toString();
    num n(String key) => num.tryParse('${j[key] ?? 0}') ?? 0;

    return Book(
      id: s('_id'),
      title: s('title'),
      author: s('author'),
      translator: s('translator'),
      publisher: s('publisher'),
      category: s('category'),
      language: s('language'),
      binding: s('binding'),
      img: s('img'),
      description: s('description'),
      price: n('price'),
      originalPrice: n('originalPrice'),
      pages: n('pages').toInt(),
      stock: (j['stock'] == null || j['stock'] == '') ? -1 : n('stock').toInt(),
    );
  }

  // কত % ছাড়
  int get discountPercent {
    if (originalPrice > price && price > 0) {
      return (((originalPrice - price) / originalPrice) * 100).round();
    }
    return 0;
  }

  bool get inStock => stock != 0;
}