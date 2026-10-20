import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _isRegister = false;
  bool _loading = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthState>();
    final error = _isRegister
        ? await auth.register(_name.text, _email.text, _password.text)
        : await auth.login(_email.text, _password.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isRegister ? 'Account খোলা হয়েছে' : 'Login সফল হয়েছে')),
      );
      Navigator.pop(context);
    } else {
      setState(() => _error = error);
    }
  }

  Future<void> _forgotPassword() async {
    if (_email.text.trim().isEmpty) {
      setState(() => _error = 'আগে উপরে আপনার ইমেইল লিখুন');
      return;
    }
    final error = await context.read<AuthState>().resetPassword(_email.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'পাসওয়ার্ড বদলানোর লিংক আপনার ইমেইলে পাঠানো হয়েছে'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'নতুন Account' : 'Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Icon(Icons.menu_book_rounded, size: 64, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text(
                  'বারাকাহ বুকস',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 28),

                if (_isRegister) ...[
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'আপনার নাম',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'নাম লিখুন' : null,
                  ),
                  const SizedBox(height: 14),
                ],

                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'ইমেইল',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || !v.contains('@')) ? 'সঠিক ইমেইল লিখুন' : null,
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _password,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(
                    labelText: 'পাসওয়ার্ড',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে' : null,
                ),

                if (!_isRegister)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('পাসওয়ার্ড ভুলে গেছেন?'),
                    ),
                  ),

                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 16),

                FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isRegister ? 'Account খুলুন' : 'Login করুন',
                          style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => setState(() {
                    _isRegister = !_isRegister;
                    _error = null;
                  }),
                  child: Text(_isRegister
                      ? 'আগেই account আছে? Login করুন'
                      : 'নতুন? Account খুলুন'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}