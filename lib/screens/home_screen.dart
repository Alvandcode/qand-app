import 'package:flutter/material.dart';
import '../theme/qand_theme.dart';
import '../data/demo_products.dart';
import '../models/product.dart';
import '../services/auth_service.dart';
import 'product_detail_screen.dart';
import 'track_order_screen.dart';
import 'chat_screen.dart';
import 'admin_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selected = 0;
  int _tab = 0;

  Product get current => demoProducts[_selected];

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.username == 'admin';
    return Scaffold(
      body: _tab == 0 ? _homeBody() : _tab == 1
          ? TrackOrderScreen(username: widget.username)
          : _tab == 2
              ? const ChatScreen()
              : AdminScreen(username: widget.username),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16)]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(Icons.home, 0),
            _nav(Icons.receipt_long, 1),
            _nav(Icons.chat_bubble_outline, 2),
            if (isAdmin) _nav(Icons.admin_panel_settings_outlined, 3),
            IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _nav(IconData ic, int i) {
    final on = _tab == i;
    return IconButton(
      onPressed: () => setState(() => _tab = i),
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: on ? QandTheme.red : Colors.transparent, shape: BoxShape.circle),
        child: Icon(ic, color: on ? Colors.white : Colors.grey),
      ),
    );
  }

  Widget _homeBody() {
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          decoration: QandTheme.headerGradient(),
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 130),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('سلام ${widget.username} 👋', style: const TextStyle(color: Colors.white, fontSize: 18)),
              const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.notifications_none, color: Colors.white)),
            ]),
            const SizedBox(height: 6),
            const Text('امروز چی برات بپزم؟', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Image.asset('assets/logo/chef.png', height: 190, errorBuilder: (_, __, ___) =>
              Container(height: 190, width: 190, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Center(child: Text('👩‍🍳', style: TextStyle(fontSize: 90))))),
          ]),
        ),
        Transform.translate(
          offset: const Offset(0, -90),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  const Text('یکی رو انتخاب کن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 118,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      itemCount: demoProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final p = demoProducts[i];
                        final on = i == _selected;
                        return GestureDetector(
                          onTap: () => setState(() => _selected = i),
                          child: Column(children: [
                            Container(
                              width: on ? 76 : 66, height: on ? 76 : 66,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: on ? QandTheme.red : Colors.grey.shade200, width: on ? 3 : 1),
                                color: QandTheme.cream,
                              ),
                              child: ClipOval(child: Image.asset(p.asset, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(child: Text(p.title.characters.first)))),
                            ),
                            const SizedBox(height: 6),
                            Text(p.title, style: TextStyle(fontSize: 12, fontWeight: on ? FontWeight.bold : FontWeight.normal, color: on ? QandTheme.red : Colors.black87)),
                          ]),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: QandTheme.cream, borderRadius: BorderRadius.circular(20)),
                    child: Text('✨ ${current.title} تازه و خونگی', style: const TextStyle(fontSize: 13)),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: current, username: widget.username))),
                      child: const Text('ادامه'),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false);
  }
}
