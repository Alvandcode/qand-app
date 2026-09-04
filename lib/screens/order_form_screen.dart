import 'package:flutter/material.dart';
import '../theme/qand_theme.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'track_order_screen.dart';

class OrderFormScreen extends StatefulWidget {
  final Product product;
  final String username;
  const OrderFormScreen({super.key, required this.product, required this.username});
  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();
  int _qty = 1;
  int _persons = 4;
  DateTime _date = DateTime.now().add(const Duration(days: 2));

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _address.dispose(); _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (!_formKeyValid()) return;
    final order = QandOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: widget.product.id,
      productTitle: widget.product.title,
      qty: _qty,
      persons: _persons,
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      deliveryDate: '${_date.year}/${_date.month.toString().padLeft(2, '0')}/${_date.day.toString().padLeft(2, '0')}',
      note: _note.text.trim(),
      status: OrderStatuses.pending,
      totalPrice: widget.product.price * _qty,
      createdAt: DateTime.now().toIso8601String(),
    );
    await OrderService().add(order);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سفارشت ثبت شد، منتظر اعلام مبلغ توسط مدیر باش 🌸')));
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TrackOrderScreen(username: widget.username)));
  }

  bool _formKeyValid() {
    if (!_form.currentState!.validate()) return false;
    if (!RegExp(r'^09\d{9}$').hasMatch(_phone.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شماره تماس باید مثل 09130000000 باشد')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(decoration: QandTheme.headerGradient(radius: 24),
          child: SafeArea(child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_forward, color: Colors.white)),
            Text('سفارش ${widget.product.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
          ]))),
      ),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          _counter('تعداد سفارش', _qty, (v) => setState(() => _qty = v)),
          _counter('تعداد نفرات', _persons, (v) => setState(() => _persons = v), min: 1, max: 200),
          _field(_name, 'نام و نام خانوادگی', Icons.person, need: true),
          _field(_phone, 'شماره تماس (09...)', Icons.phone, kb: TextInputType.phone, need: true),
          _field(_address, 'آدرس دقیق محل دریافت', Icons.location_on, lines: 2, need: true),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
            tileColor: Colors.white,
            leading: const Icon(Icons.calendar_month, color: QandTheme.red),
            title: const Text('تاریخ دریافت سفارش'),
            subtitle: Text('${_date.year}/${_date.month}/${_date.day}'),
            trailing: const Icon(Icons.edit),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          _field(_note, 'توضیح اضافه (اختیاری)', Icons.note_alt_outlined, lines: 2),
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: QandTheme.cream, borderRadius: BorderRadius.circular(16)),
            child: Text('مبلغ تقریبی: ${(widget.product.price * _qty).toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')} تومان\nمبلغ نهایی را مدیر اعلام می‌کند.',
              style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 14),
          ElevatedButton(onPressed: _submit, child: const Text('ارسال سفارش')),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String h, IconData ic, {bool need = false, int lines = 1, TextInputType? kb}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c, maxLines: lines, keyboardType: kb,
        decoration: InputDecoration(labelText: h, prefixIcon: Icon(ic)),
        validator: need ? (v) => (v == null || v.trim().isEmpty) ? 'این فیلد لازم است' : null : null,
      ),
    );
  }

  Widget _counter(String t, int v, ValueChanged<int> on, {int min = 1, int max = 50}) {
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: [
          IconButton(onPressed: v > min ? () => on(v - 1) : null, icon: const Icon(Icons.remove_circle_outline)),
          Text('$v', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(onPressed: v < max ? () => on(v + 1) : null, icon: const Icon(Icons.add_circle, color: QandTheme.red)),
        ]),
      ]),
    ));
  }
}
