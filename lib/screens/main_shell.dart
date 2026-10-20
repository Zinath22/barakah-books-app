import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/utils.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

// নিচের menu bar: হোম, কার্ট, প্রোফাইল
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().count;

    Widget cartIcon(IconData icon) => Badge(
          isLabelVisible: count > 0,
          label: Text(toBn(count)),
          child: Icon(icon),
        );

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), CartScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: cartIcon(Icons.shopping_cart_outlined),
            selectedIcon: cartIcon(Icons.shopping_cart),
            label: 'কার্ট',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }
}