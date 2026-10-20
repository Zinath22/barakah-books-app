const _bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];

// 123 → ১২৩
String toBn(Object value) =>
    value.toString().replaceAllMapped(RegExp(r'\d'), (m) => _bnDigits[int.parse(m[0]!)]);

// 480 → ৳ ৪৮০
String taka(num value) => '৳ ${toBn(value.round())}';

// website এর মতো একই ৮টা ক্যাটাগরি
const categories = [
  'কুরআন ও তাফসীর',
  'হাদিস',
  'সীরাত',
  'ফিকহ ও মাসায়েল',
  'আকীদা',
  'আত্মশুদ্ধি',
  'শিশু-কিশোর',
  'ইতিহাস',
];