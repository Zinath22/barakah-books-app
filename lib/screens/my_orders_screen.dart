import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    // initState-এ setState লাগে না, সরাসরি সেট করলেই হবে
    _future = OrderService.myOrders();
  }

  /// নতুন করে অর্ডার আনবে (pull-to-refresh, বাতিলের পরে, আবার চেষ্টা)
  Future<void> _refresh() async {
    final f = OrderService.myOrders();
    setState(() {
      _future = f; // { } ব্লক — কিছু return করে না, তাই আর error হবে না
    });
    try {
      await f; // ডেটা আসা পর্যন্ত refresh চাকা ঘুরবে
    } catch (_) {
      // error FutureBuilder নিজেই দেখাবে
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'approved':
      case 'confirmed':
        return AppColors.primary;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _cancel(Order order) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('অর্ডার বাতিল করবেন?'),
        content: Text('অর্ডার #${order.shortId} বাতিল হয়ে যাবে'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('হ্যাঁ, বাতিল')),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await OrderService.cancel(order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অর্ডার বাতিল করা হয়েছে')),
      );
      await _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আমার অর্ডার')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Order>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(child: Text(snap.error.toString(), textAlign: TextAlign.center)),
                  const SizedBox(height: 12),
                  Center(
                    child: FilledButton(onPressed: _refresh, child: const Text('আবার চেষ্টা করুন')),
                  ),
                ],
              );
            }
            final orders = snap.data ?? [];
            if (orders.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 160),
                  Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Center(child: Text('এখনো কোনো অর্ডার করেননি')),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final o = orders[i];
                final color = _statusColor(o.status);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('#${o.shortId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(dateBn(o.createdAt), style: TextStyle(color: Colors.grey.shade600)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(orderStatusBn(o.status),
                                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      ...o.items.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Expanded(child: Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                Text('${toBn(it.qty)} × ${taka(it.price)}',
                                    style: TextStyle(color: Colors.grey.shade700)),
                              ],
                            ),
                          )),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Text(o.paymentMethod == 'COD' ? 'ক্যাশ অন ডেলিভারি' : o.paymentMethod,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const Spacer(),
                          Text(taka(o.total),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      if (o.status.toLowerCase() == 'pending')
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _cancel(o),
                            icon: const Icon(Icons.close, color: Colors.red, size: 18),
                            label: const Text('অর্ডার বাতিল করুন', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}