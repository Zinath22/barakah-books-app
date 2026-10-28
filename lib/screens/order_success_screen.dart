import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/order.dart';
import 'my_orders_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;
  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, size: 96, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('জাযাকাল্লাহু খাইরান!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('আপনার অর্ডার সফলভাবে গ্রহণ করা হয়েছে',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Text('অর্ডার নম্বর: #${order.shortId}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('সর্বমোট: ${taka(order.total)} (ক্যাশ অন ডেলিভারি)'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
                ),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('আমার অর্ডার দেখুন'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('কেনাকাটা চালিয়ে যান'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}