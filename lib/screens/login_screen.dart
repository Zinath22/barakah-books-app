// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/theme.dart';
// import '../providers/auth_state.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _name = TextEditingController();
//   final _email = TextEditingController();
//   final _password = TextEditingController();

//   bool _isRegister = false;
//   bool _loading = false;
//   bool _hidePassword = true;
//   String? _error;

//   @override
//   void dispose() {
//     _name.dispose();
//     _email.dispose();
//     _password.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     final auth = context.read<AuthState>();
//     final error = _isRegister
//         ? await auth.register(_name.text, _email.text, _password.text)
//         : await auth.login(_email.text, _password.text);

//     if (!mounted) return;
//     setState(() => _loading = false);

//     if (error == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(_isRegister ? 'Account খোলা হয়েছে' : 'Login সফল হয়েছে')),
//       );
//       Navigator.pop(context);
//     } else {
//       setState(() => _error = error);
//     }
//   }

//   Future<void> _forgotPassword() async {
//     if (_email.text.trim().isEmpty) {
//       setState(() => _error = 'আগে উপরে আপনার ইমেইল লিখুন');
//       return;
//     }
//     final error = await context.read<AuthState>().resetPassword(_email.text);
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(error ?? 'পাসওয়ার্ড বদলানোর লিংক আপনার ইমেইলে পাঠানো হয়েছে'),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(_isRegister ? 'নতুন Account' : 'Login')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 12),
//                 const Icon(Icons.menu_book_rounded, size: 64, color: AppColors.primary),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'বারাকাহ বুকস',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
//                 ),
//                 const SizedBox(height: 28),

//                 if (_isRegister) ...[
//                   TextFormField(
//                     controller: _name,
//                     decoration: const InputDecoration(
//                       labelText: 'আপনার নাম',
//                       prefixIcon: Icon(Icons.person_outline),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (v) => (v == null || v.trim().isEmpty) ? 'নাম লিখুন' : null,
//                   ),
//                   const SizedBox(height: 14),
//                 ],

//                 TextFormField(
//                   controller: _email,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: const InputDecoration(
//                     labelText: 'ইমেইল',
//                     prefixIcon: Icon(Icons.email_outlined),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (v) => (v == null || !v.contains('@')) ? 'সঠিক ইমেইল লিখুন' : null,
//                 ),
//                 const SizedBox(height: 14),

//                 TextFormField(
//                   controller: _password,
//                   obscureText: _hidePassword,
//                   decoration: InputDecoration(
//                     labelText: 'পাসওয়ার্ড',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     border: const OutlineInputBorder(),
//                     suffixIcon: IconButton(
//                       icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
//                       onPressed: () => setState(() => _hidePassword = !_hidePassword),
//                     ),
//                   ),
//                   validator: (v) =>
//                       (v == null || v.length < 6) ? 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে' : null,
//                 ),

//                 if (!_isRegister)
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: TextButton(
//                       onPressed: _forgotPassword,
//                       child: const Text('পাসওয়ার্ড ভুলে গেছেন?'),
//                     ),
//                   ),

//                 if (_error != null) ...[
//                   const SizedBox(height: 8),
//                   Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
//                 ],
//                 const SizedBox(height: 16),

//                 FilledButton(
//                   onPressed: _loading ? null : _submit,
//                   style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
//                   child: _loading
//                       ? const SizedBox(
//                           width: 22,
//                           height: 22,
//                           child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                         )
//                       : Text(_isRegister ? 'Account খুলুন' : 'Login করুন',
//                           style: const TextStyle(fontSize: 16)),
//                 ),
//                 const SizedBox(height: 12),

//                 TextButton(
//                   onPressed: () => setState(() {
//                     _isRegister = !_isRegister;
//                     _error = null;
//                   }),
//                   child: Text(_isRegister
//                       ? 'আগেই account আছে? Login করুন'
//                       : 'নতুন? Account খুলুন'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


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
  bool _needsVerify = false; // যাচাই বাকি থাকলে "আবার পাঠান" বাটন দেখাবে
  bool _resending = false;
  String? _error;
  String? _info; // সবুজ বক্সের বার্তা

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
      _info = null;
      _needsVerify = false;
    });

    final auth = context.read<AuthState>();

    // ---------- নতুন account ----------
    if (_isRegister) {
      final error = await auth.register(_name.text, _email.text, _password.text);
      if (!mounted) return;
      if (error == null) {
        // Login মোডে ফিরে যাওয়া, ইমেইল রেখে দেওয়া
        setState(() {
          _loading = false;
          _isRegister = false;
          _password.clear();
          _info = 'Account খোলা হয়েছে! ${_email.text.trim()} এ একটি যাচাইয়ের লিংক পাঠানো হয়েছে। '
              'লিংকে চাপুন, তারপর এখানে Login করুন। ইমেইল না পেলে Spam ফোল্ডার দেখুন।';
        });
      } else {
        setState(() {
          _loading = false;
          _error = error;
        });
      }
      return;
    }

    // ---------- Login ----------
    final error = await auth.login(_email.text, _password.text);
    if (!mounted) return;

    if (error == null) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login সফল হয়েছে')),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        _loading = false;
        _error = error;
        _needsVerify = error == authErrorBn(kEmailNotVerified);
      });
    }
  }

  Future<void> _resend() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() {
        _error = 'ইমেইল আর পাসওয়ার্ড লিখে তারপর চাপুন';
      });
      return;
    }
    setState(() {
      _resending = true;
    });
    final result = await context.read<AuthState>().resendVerification(_email.text, _password.text);
    if (!mounted) return;
    setState(() {
      _resending = false;
      if (result.ok) {
        _error = null;
        _needsVerify = false;
        _info = result.message;
      } else {
        _error = result.message;
      }
    });
  }

  Future<void> _forgotPassword() async {
    if (_email.text.trim().isEmpty) {
      setState(() {
        _error = 'আগে উপরে আপনার ইমেইল লিখুন';
      });
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

                // ✅ সবুজ বার্তা (রেজিস্টার বা আবার পাঠানোর পর)
                if (_info != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.mark_email_read_outlined, color: Colors.green.shade700),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_info!, style: TextStyle(color: Colors.green.shade900, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

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
                      onPressed: () {
                        setState(() {
                          _hidePassword = !_hidePassword;
                        });
                      },
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

                // ❌ লাল বার্তা
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ],

                // 📧 যাচাই বাকি থাকলে
                if (_needsVerify) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _resending ? null : _resend,
                    icon: _resending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.forward_to_inbox_outlined),
                    label: const Text('যাচাইয়ের ইমেইল আবার পাঠান'),
                  ),
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
                  onPressed: () {
                    setState(() {
                      _isRegister = !_isRegister;
                      _error = null;
                      _info = null;
                      _needsVerify = false;
                    });
                  },
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