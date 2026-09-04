import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/qand_theme.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/settings_service.dart';

class PaymentScreen extends StatefulWidget {
  final QandOrder order;
  const PaymentScreen({super.key, required this.order});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _card = '';
  String _owner = '';
  String _zarin = '';
  String? _receipt;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _receipt = widget.order.receiptPath;
    SettingsService().load().then((m) => setState(() {
          _card = m['card']!;
          _owner = m['owner']!;
          _zarin = m['zarin']!;
        }));
  }

  Future<void> _pickReceipt() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img == null) return;
    setState(() => _receipt = img.path);
    await OrderService().updateStatus(widget.order.id, OrderStatuses.receiptSent, receiptPath: img.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فیش ارسال شد، منتظر تایید مدیر باش 🙏')));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(decoration: QandTheme.headerGradient(radius: 24),
          child: SafeArea(child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_forward, color: Colors.white)),
            const Text('پرداخت و فیش', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          ]))),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.order.productTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          Text('مبلغ اعلامی مدیر: ${widget.order.totalPrice} تومان', style: const TextStyle(fontWeight: FontWeight.bold, color: QandTheme.red, fontSize: 16)),
          Text('وضعیت: ${OrderStatuses.fa(widget.order.status)}'),
        ]))),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('کارت‌به‌کارت', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SelectableText(_card.isEmpty ? '...' : _card, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
          Text('به نام $_owner'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {
              Clipboard.setData(ClipboardData(text: _card));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شماره کارت کپی شد')));
            }, icon: const Icon(Icons.copy), label: const Text('کپی شماره کارت'))),
          ]),
          if (_zarin.isNotEmpty) ...[
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => launchUrl(Uri.parse(_zarin), mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.credit_card),
              label: const Text('پرداخت آنلاین (زرین‌پال)'),
            ),
          ] else const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('پرداخت آنلاین به‌زودی فعال می‌شود.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
        ]))),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('فیش واریزی', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_receipt != null) const Icon(Icons.receipt_long, size: 64, color: QandTheme.red),
          Text(_receipt ?? 'هنوز فیشی نفرستادی', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _sending ? null : _pickReceipt,
            icon: const Icon(Icons.upload),
            label: Text(_receipt == null ? 'انتخاب و ارسال فیش' : 'ارسال مجدد فیش'),
          ),
        ]))),
      ]),
    );
  }
}
