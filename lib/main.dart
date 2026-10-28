import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_state.dart';
import 'providers/cart_provider.dart';
import 'screens/main_shell.dart';
import 'providers/wishlist_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
         ChangeNotifierProvider(create: (_) => WishlistProvider()), 
      ],
      child: const BarakahBooksApp(),
    ),
  );
}

class BarakahBooksApp extends StatelessWidget {
  const BarakahBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'বারাকাহ বুকস',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const MainShell(),
    );
  }
}