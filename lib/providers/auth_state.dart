// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import '../core/api.dart';

// // Login এর অবস্থা পুরো অ্যাপে এখান থেকে জানা যায়
// class AuthState extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   User? user;
//   String role = 'user';

//   AuthState() {
//     // অ্যাপ খুললে আগের login মনে রাখে
//     _auth.authStateChanges().listen((u) async {
//       user = u;
//       if (u != null) {
//         await _syncWithServer();
//       } else {
//         role = 'user';
//       }
//       notifyListeners();
//     });
//   }

//   bool get isLoggedIn => user != null;
//   bool get isAdmin => role == 'admin';

//   String get name {
//     final n = user?.displayName ?? '';
//     if (n.isNotEmpty) return n;
//     return user?.email?.split('@').first ?? '';
//   }

//   // Server এর MongoDB তে user save করা আর role (admin কিনা) জানা
//   Future<void> _syncWithServer({String? name}) async {
//     try {
//       final res = await Api.dio.post('/users/save', data: {
//         if (name != null && name.isNotEmpty) 'name': name,
//       });
//       role = (res.data['user']?['role'] ?? 'user').toString();
//     } catch (e) {
//       debugPrint('USER SYNC ERROR: $e');
//     }
//   }

//   Future<String?> login(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
//       return null; // null মানে সফল
//     } on FirebaseAuthException catch (e) {
//       return authErrorBn(e.code);
//     }
//   }

//   Future<String?> register(String name, String email, String password) async {
//     try {
//       final cred = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password,
//       );
//       await cred.user?.updateDisplayName(name.trim());
//       await cred.user?.reload();
//       user = _auth.currentUser;
//       await _syncWithServer(name: name.trim());
//       notifyListeners();
//       return null;
//     } on FirebaseAuthException catch (e) {
//       return authErrorBn(e.code);
//     }
//   }

//   Future<String?> resetPassword(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//       return null;
//     } on FirebaseAuthException catch (e) {
//       return authErrorBn(e.code);
//     }
//   }

//   Future<void> logout() => _auth.signOut();
// }

// // Firebase এর ইংরেজি error গুলো বাংলায়
// String authErrorBn(String code) {
//   switch (code) {
//     case 'invalid-email':
//       return 'ইমেইলটি সঠিক নয়';
//     case 'user-not-found':
//     case 'wrong-password':
//     case 'invalid-credential':
//       return 'ইমেইল বা পাসওয়ার্ড ভুল';
//     case 'email-already-in-use':
//       return 'এই ইমেইল দিয়ে আগেই account খোলা আছে। Login করুন';
//     case 'weak-password':
//       return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
//     case 'too-many-requests':
//       return 'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন';
//     case 'network-request-failed':
//       return 'Internet সংযোগ নেই';
//     default:
//       return 'সমস্যা হয়েছে ($code)';
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/api.dart';

/// ইমেইল যাচাই না হলে login এই বার্তা ফেরত দেয় — login screen এটা দেখে "আবার পাঠান" বাটন দেখায়
const String kEmailNotVerified = 'email-not-verified';

// Login এর অবস্থা পুরো অ্যাপে এখান থেকে জানা যায়
class AuthState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? user;
  String role = 'user';

  AuthState() {
    // অ্যাপ খুললে আগের login মনে রাখে
    _auth.authStateChanges().listen((u) async {
      if (u == null) {
        user = null;
        role = 'user';
        notifyListeners();
        return;
      }

      // সর্বশেষ অবস্থা আনা (ইমেইল যাচাই হয়েছে কিনা)
      User? fresh = u;
      try {
        await u.reload();
        fresh = _auth.currentUser;
      } catch (_) {
        // internet না থাকলে আগের তথ্য দিয়েই চলবে
      }

      // ইমেইল যাচাই না হলে login ধরা হবে না
      if (fresh == null || !fresh.emailVerified) {
        user = null;
        role = 'user';
        notifyListeners();
        return;
      }

      user = fresh;
      await _syncWithServer(name: fresh.displayName);
      notifyListeners();
    });
  }

  bool get isLoggedIn => user != null;
  bool get isAdmin => role == 'admin';

  String get name {
    final n = user?.displayName ?? '';
    if (n.isNotEmpty) return n;
    return user?.email?.split('@').first ?? '';
  }

  // Server এর MongoDB তে user save করা আর role (admin কিনা) জানা
  Future<void> _syncWithServer({String? name}) async {
    try {
      final res = await Api.dio.post('/users/save', data: {
        if (name != null && name.isNotEmpty) 'name': name,
      });
      role = (res.data['user']?['role'] ?? 'user').toString();
    } catch (e) {
      debugPrint('USER SYNC ERROR: $e');
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.reload();
      final fresh = _auth.currentUser;

      if (fresh != null && !fresh.emailVerified) {
        await _auth.signOut();
        return authErrorBn(kEmailNotVerified);
      }
      return null; // null মানে সফল
    } on FirebaseAuthException catch (e) {
      return authErrorBn(e.code);
    }
  }

  /// নতুন account খোলে, যাচাইয়ের ইমেইল পাঠায়, তারপর logout করে
  Future<String?> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name.trim());
      await cred.user?.sendEmailVerification();
      await _auth.signOut(); // যাচাইয়ের পর নিজে login করবে
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorBn(e.code);
    }
  }

  /// যাচাইয়ের ইমেইল আবার পাঠায় (ইমেইল আর পাসওয়ার্ড লাগে)
  Future<({bool ok, String message})> resendVerification(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.reload();
      final fresh = _auth.currentUser;

      if (fresh != null && fresh.emailVerified) {
        await _auth.signOut();
        return (ok: true, message: 'ইমেইল আগেই যাচাই হয়ে গেছে। এখন Login করুন');
      }

      await fresh?.sendEmailVerification();
      await _auth.signOut();
      return (ok: true, message: 'যাচাইয়ের লিংক আবার ${email.trim()} এ পাঠানো হয়েছে');
    } on FirebaseAuthException catch (e) {
      return (ok: false, message: authErrorBn(e.code));
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return authErrorBn(e.code);
    }
  }

  Future<void> logout() => _auth.signOut();
}

// Firebase এর ইংরেজি error গুলো বাংলায়
String authErrorBn(String code) {
  switch (code) {
    case kEmailNotVerified:
      return 'আগে ইমেইল যাচাই করুন। আপনার ইমেইলে পাঠানো লিংকে চাপুন, তারপর Login করুন';
    case 'invalid-email':
      return 'ইমেইলটি সঠিক নয়';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'ইমেইল বা পাসওয়ার্ড ভুল';
    case 'email-already-in-use':
      return 'এই ইমেইল দিয়ে আগেই account খোলা আছে। Login করুন';
    case 'weak-password':
      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
    case 'too-many-requests':
      return 'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন';
    case 'network-request-failed':
      return 'Internet সংযোগ নেই';
    default:
      return 'সমস্যা হয়েছে ($code)';
  }
}