import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../providers/auth_state.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _phone = TextEditingController();
  final _city = TextEditingController(text: 'ঢাকা');
  final _address = TextEditingController();
  final _coupon = TextEditingController();

  String? _appliedCoupon;
  num _discount = 0;
  bool _checkingCoupon = false;
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<AuthState>().name);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    _coupon.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _applyCoupon(num subtotal) async {
    final code = _coupon.text.trim();
    if (code.isEmpty) return;
    setState(() => _checkingCoupon = true);
    try {
      final data = await OrderService.validateCoupon(code, subtotal);
      setState(() {
        _appliedCoupon = code;
        _discount = num.tryParse('${data['discountAmount'] ?? 0}') ?? 0;
      });
      _snack('কুপন যোগ হয়েছে');
    } catch (e) {
      setState(() {
        _appliedCoupon = null;
        _discount = 0;
      });
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _checkingCoupon = false);
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    setState(() => _placing = true);
    try {
      final order = await OrderService.placeCodOrder(
        items: cart.items,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        couponCode: _appliedCoupon,
      );
      cart.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
      );
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  InputDecoration _input(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final total = (cart.subtotal - _discount).clamp(0, double.infinity);

    return Scaffold(
      appBar: AppBar(title: const Text('অর্ডার নিশ্চিত করুন')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('ডেলিভারির ঠিকানা',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: _input('নাম', Icons.person_outline),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'নাম লিখুন' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: _input('মোবাইল নম্বর', Icons.phone_outlined),
              validator: (v) {
                final p = (v ?? '').replaceAll(RegExp(r'[\s-]'), '').replaceFirst('+88', '');
                return RegExp(r'^01[3-9]\d{8}$').hasMatch(p) ? null : 'সঠিক ১১ সংখ্যার মোবাইল নম্বর লিখুন';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _city,
              decoration: _input('জেলা', Icons.location_city_outlined),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'জেলা লিখুন' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: _input('বিস্তারিত ঠিকানা (বাসা, রোড, এলাকা)', Icons.home_outlined),
              validator: (v) =>
                  (v == null || v.trim().length < 5) ? 'বিস্তারিত ঠিকানা লিখুন' : null,
            ),
            const SizedBox(height: 24),

            // কুপন
            const Text('কুপন', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coupon,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _input('কুপন কোড (থাকলে)', Icons.local_offer_outlined),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _checkingCoupon ? null : () => _applyCoupon(cart.subtotal),
                  child: _checkingCoupon
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('প্রয়োগ'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // হিসাব
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _row('বইয়ের দাম (${toBn(cart.count)}টি)', taka(cart.subtotal)),
                  if (_discount > 0) _row('কুপন ছাড় ($_appliedCoupon)', '− ${taka(_discount)}'),
                  _row('পেমেন্ট', 'ক্যাশ অন ডেলিভারি'),
                  const Divider(height: 24),
                  _row('সর্বমোট', taka(total), bold: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('বই হাতে পেয়ে ডেলিভারি ম্যানকে টাকা দেবেন',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),

            FilledButton(
              onPressed: _placing || cart.items.isEmpty ? null : _placeOrder,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: _placing
                  ? const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('অর্ডার কনফার্ম করুন — ${taka(total)}', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? AppColors.primary : null,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}