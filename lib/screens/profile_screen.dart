import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/auth_state.dart';
import '../providers/wishlist_provider.dart';
import 'login_screen.dart';
import 'my_orders_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(title: const Text('প্রোফাইল')),
      body: auth.isLoggedIn ? _loggedIn(context, auth) : _loggedOut(context),
    );
  }

  // Login করা না থাকলে
  Widget _loggedOut(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('আপনি এখনো login করেননি', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text('অর্ডার করতে আর অর্ডারের অবস্থা দেখতে login করুন',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              style: FilledButton.styleFrom(minimumSize: const Size(200, 48)),
              child: const Text('Login / Account খুলুন'),
            ),
          ],
        ),
      ),
    );
  }

  // Login করা থাকলে
  Widget _loggedIn(BuildContext context, AuthState auth) {
    final initial = auth.name.isNotEmpty ? auth.name[0].toUpperCase() : 'U';
    final wishCount = context.watch<WishlistProvider>().count;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // নাম, ইমেইল, অ্যাডমিন ব্যাজ
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(initial,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(auth.user?.email ?? '', style: TextStyle(color: Colors.grey.shade600)),
                    if (auth.isAdmin)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('অ্যাডমিন', style: TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // মেনু
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              // আমার অর্ডার
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('আমার অর্ডার'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                ),
              ),
              const Divider(height: 1),

              // ❤️ উইশলিস্ট (নতুন)
              ListTile(
                leading: const Icon(Icons.favorite_border, color: Colors.red),
                title: const Text('উইশলিস্ট'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (wishCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(toBn(wishCount),
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                ),
              ),
              const Divider(height: 1),

              // Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await auth.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout হয়েছে')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}