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

// অর্ডারের অবস্থা বাংলায়
String orderStatusBn(String s) => switch (s.toLowerCase()) {
      'pending' => 'অপেক্ষমাণ',
      'approved' || 'confirmed' => 'নিশ্চিত হয়েছে',
      'shipped' => 'পাঠানো হয়েছে',
      'delivered' => 'পৌঁছে গেছে',
      'cancelled' || 'rejected' => 'বাতিল',
      _ => s,
    };

// তারিখ: ১৮/১০/২০২৬
String dateBn(DateTime? d) {
  if (d == null) return '';
  return toBn('${d.day}/${d.month}/${d.year}');
}

