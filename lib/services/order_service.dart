import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

/// ذخیره سفارش‌ها فعلا لوکال (لیست JSON). با اتصال سوپابیس همین متدها به جدول orders وصل می‌شوند.
class OrderService {
  static const _k = 'qand_orders';

  Future<List<QandOrder>> all({String? forUser}) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_k) ?? [];
    final list = raw.map(_decode).toList();
    if (forUser != null) return list.where((o) => o.fullName == forUser || true).toList();
    return list;
  }

  Future<void> add(QandOrder o) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_k) ?? [];
    raw.add(_encode(o));
    await p.setStringList(_k, raw);
  }

  Future<void> updateStatus(String id, String status, {String? receiptPath, int? totalPrice}) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_k) ?? [];
    final list = raw.map(_decode).toList();
    final i = list.indexWhere((e) => e.id == id);
    if (i == -1) return;
    list[i] = list[i].copyWith(status: status, receiptPath: receiptPath, totalPrice: totalPrice);
    await p.setStringList(_k, list.map(_encode).toList());
  }

  String _encode(QandOrder o) => jsonEncode({
        'id': o.id, 'productId': o.productId, 'productTitle': o.productTitle,
        'qty': o.qty, 'persons': o.persons, 'fullName': o.fullName,
        'phone': o.phone, 'address': o.address, 'deliveryDate': o.deliveryDate,
        'note': o.note, 'status': o.status, 'totalPrice': o.totalPrice,
        'receiptPath': o.receiptPath, 'createdAt': o.createdAt,
      });

  QandOrder _decode(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return QandOrder(
      id: '${m['id']}', productId: '${m['productId']}', productTitle: '${m['productTitle']}',
      qty: (m['qty'] as num).toInt(), persons: (m['persons'] as num).toInt(),
      fullName: '${m['fullName']}', phone: '${m['phone']}', address: '${m['address']}',
      deliveryDate: '${m['deliveryDate']}', note: '${m['note'] ?? ''}',
      status: '${m['status']}', totalPrice: (m['totalPrice'] as num).toInt(),
      receiptPath: m['receiptPath'] as String?, createdAt: '${m['createdAt']}',
    );
  }
}
