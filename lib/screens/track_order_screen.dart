import 'package:flutter/material.dart';
import '../theme/qand_theme.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'payment_screen.dart';
import 'chat_screen.dart';

class TrackOrderScreen extends StatefulWidget {
  final String username;
  const TrackOrderScreen({super.key, required this.username});
  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  List<QandOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _orders = await OrderService().all();
    _orders = _orders.reversed.toList();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(decoration: QandTheme.headerGradient(radius: 24),
          child: const SafeArea(child: Center(child: Text('پیگیری سفارش‌ها', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17))))),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('هنوز سفارشی ثبت نکردی 🍰\nاز صفحه اصلی یک محصول انتخاب کن.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: _orders.length,
                    itemBuilder: (_, i) => _card(_orders[i]),
                  ),
                ),
    );
  }

  Widget _card(QandOrder o) {
    final idx = OrderStatuses.flow.indexOf(o.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(o.productTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: o.status == OrderStatuses.cancelled ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text(OrderStatuses.fa(o.status), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 6),
          Text('تعداد: ${o.qty} | نفرات: ${o.persons} | تحویل: ${o.deliveryDate}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          Text('آدرس: ${o.address}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 10),
          // تایم‌لاین ساده
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (var s = 0; s < OrderStatuses.flow.length; s++)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: s <= idx ? QandTheme.red : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10)),
                child: Text(OrderStatuses.fa(OrderStatuses.flow[s]).split('،').first,
                  style: TextStyle(fontSize: 10, color: s <= idx ? Colors.white : Colors.black54))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(order: o))).then((_) => _load()),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
                child: const Text('پرداخت / ارسال فیش'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
              icon: const Icon(Icons.support_agent),
              tooltip: 'ارتباط با مدیر',
            ),
          ]),
        ]),
      ),
    );
  }
}
