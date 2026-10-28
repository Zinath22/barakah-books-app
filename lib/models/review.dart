class Review {
  final String id;
  final String userName;
  final String userEmail;
  final String? userImage;
  final int rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> j) {
    final email = (j['userEmail'] ?? '').toString();
    final name = (j['userName'] ?? '').toString();
    final img = (j['userImage'] ?? '').toString();
    return Review(
      id: (j['_id'] ?? '').toString(),
      userEmail: email,
      // নাম না থাকলে ইমেইলের প্রথম অংশ দেখাবে
      userName: name.isNotEmpty ? name : (email.isNotEmpty ? email.split('@').first : 'পাঠক'),
      userImage: img.isEmpty ? null : img,
      rating: (j['rating'] as num?)?.toInt() ?? 0,
      comment: (j['comment'] ?? '').toString(),
      createdAt: DateTime.tryParse((j['createdAt'] ?? '').toString())?.toLocal() ?? DateTime.now(),
    );
  }
}