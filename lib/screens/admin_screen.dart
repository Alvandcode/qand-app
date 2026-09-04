import 'package:flutter/material.dart';
import '../theme/qand_theme.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/settings_service.dart';
import '../data/demo_products.dart';

class AdminScreen extends StatefulWidget {
  final String username;
  const AdminScreen({super.key, required this.username});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<QandOrder> _orders = [];
  final _card = TextEditingController();
  final _owner = TextEditingController();
  final _zarin = TextEditingController();
  final _price = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    _orders = await OrderService().all();
    final s = await SettingsService().load();
    _card.text = s['card']!;
    _owner.text = s['owner']!;
    _zarin.text = s['zarin']!;
    setState(() {});
  }

  Future<void> _setStatus(QandOrder o, String st) async {
    int? price;
    if (st == OrderStatuses.awaitingPayment) {
      price = await _askPrice(o.totalPrice);
      if (price == null) return;
    }
    await OrderService().updateStatus(o.id, st, totalPrice: price);
    _load();
  }

  Future<int?> _askPrice(int current) async {
    _price.text = '$current';
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مبلغ نهایی (تومان)'),
        content: TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'مثلا 450000')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('لغو')),
          ElevatedButton(onPressed: () => Navigator.pop(context, int.tryParse(_price.text.trim()) ?? current), child: const Text('ثبت + ارسال به کاربر')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.username != 'admin') {
      return const Scaffold(body: Center(child: Text('فقط مدیر دسترسی دارد 🔒')));
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140),
        child: Container(
          decoration: QandTheme.headerGradient(radius: 24),
          child: SafeArea(child: Column(children: [
            const Text('پنل مدیر قند 👩‍🍳', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            TabBar(controller: _tab, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white70,
              tabs: const [Tab(text: 'سفارش‌ها'), Tab(text: 'محصولات'), Tab(text: 'تنظیمات')]),
          ])),
        ),
      ),
      body: TabBarView(controller: _tab, children: [_ordersTab(), _productsTab(), _settingsTab()]),
    );
  }

  Widget _ordersTab() {
    if (_orders.isEmpty) return const Center(child: Text('سفارشی نیست'));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _orders.length,
      itemBuilder: (_, i) {
        final o = _orders[i];
        return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${o.productTitle} × ${o.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${o.fullName} | ${o.phone}\n${o.address}\nتحویل: ${o.deliveryDate} | مبلغ: ${o.totalPrice}', style: const TextStyle(fontSize: 13)),
            Text('وضعیت: ${OrderStatuses.fa(o.status)}', style: const TextStyle(fontWeight: FontWeight.bold, color: QandTheme.red)),
            if (o.receiptPath != null) const Text('📎 فیش ارسال شده', style: TextStyle(fontSize: 12)),
            Wrap(spacing: 6, children: [
              _stBtn(o, 'مبلغ+کارت', OrderStatuses.awaitingPayment),
              _stBtn(o, 'تایید فیش', OrderStatuses.approved),
              _stBtn(o, 'آماده', OrderStatuses.ready),
              _stBtn(o, 'تحویل', OrderStatuses.delivered),
              _stBtn(o, 'لغو', OrderStatuses.cancelled),
            ]),
          ]),
        ));
      },
    );
  }

  Widget _stBtn(QandOrder o, String t, String st) {
    return ElevatedButton(
      onPressed: () => _setStatus(o, st),
      style: ElevatedButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 10)),
      child: Text(t, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _productsTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('محصولات فعلی (دمو). مدیریت کامل با اتصال سوپابیس فعال می‌شود.', style: TextStyle(color: Colors.grey)),
        for (final p in demoProducts)
          Card(child: ListTile(
            title: Text(p.title),
            subtitle: Text('${p.price} تومان | ${p.category}'),
            trailing: const Icon(Icons.image, color: QandTheme.red),
          )),
        const SizedBox(height: 8),
        const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('➕ افزودن/حذف محصول + قیمت + توضیح + عکس از همین‌جا بعد از اتصال سوپابیس (جدول products + باکت product-images).'))),
      ],
    );
  }

  Widget _settingsTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('شماره کارت و زرین‌پال (از داخل اپ قابل تغییر)', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      TextField(controller: _card, decoration: const InputDecoration(labelText: 'شماره کارت')),
      const SizedBox(height: 10),
      TextField(controller: _owner, decoration: const InputDecoration(labelText: 'به نام')),
      const SizedBox(height: 10),
      TextField(controller: _zarin, decoration: const InputDecoration(labelText: 'لینک زرین‌پال (اختیاری، بعدا)', hintText: 'https://www.zarinpal.com/...')),
      const SizedBox(height: 14),
      ElevatedButton(onPressed: () async {
        await SettingsService().save(card: _card.text.trim(), owner: _owner.text.trim(), zarin: _zarin.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ذخیره شد ✅')));
      }, child: const Text('ذخیره تنظیمات')),
    ]);
  }
}
