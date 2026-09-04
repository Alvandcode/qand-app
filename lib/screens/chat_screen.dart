import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/qand_theme.dart';
import '../config/app_config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctl = TextEditingController();
  final List<Map<String, dynamic>> _msgs = [
    {'me': false, 't': 'سلام! به قنادی قند خوش اومدی 🌸 سوالت رو بپرس، مدیر جواب میده.'},
  ];

  void _send() {
    final t = _ctl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _msgs.add({'me': true, 't': t});
      // پاسخ خودکار دمویی؛ با اتصال سوپابیس پیام واقعی به مدیر می‌رود
      _msgs.add({'me': false, 't': 'پیامت ثبت شد، مدیر به‌زودی جواب میده 🙏'});
    });
    _ctl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(decoration: QandTheme.headerGradient(radius: 24),
          child: SafeArea(child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_forward, color: Colors.white)),
            const CircleAvatar(backgroundColor: Colors.white, child: Text('👩‍🍳')),
            const SizedBox(width: 8),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('مدیر قنادی قند', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('آنلاین', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            const Spacer(),
            IconButton(onPressed: () => launchUrl(Uri.parse('tel:${AppConfig.supportPhone}')), icon: const Icon(Icons.call, color: Colors.white)),
            IconButton(onPressed: () => launchUrl(Uri.parse('https://wa.me/${AppConfig.whatsappNumber}'), mode: LaunchMode.externalApplication), icon: const Icon(Icons.chat, color: Colors.white)),
          ]))),
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _msgs.length,
          itemBuilder: (_, i) {
            final m = _msgs[i];
            final me = m['me'] as bool;
            return Align(
              alignment: me ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: me ? QandTheme.red : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Text('${m['t']}', style: TextStyle(color: me ? Colors.white : Colors.black87)),
              ),
            );
          },
        )),
        SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: TextField(controller: _ctl, decoration: const InputDecoration(hintText: 'پیامت به مدیر...'))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: _send, icon: const Icon(Icons.send), style: IconButton.styleFrom(backgroundColor: QandTheme.red, foregroundColor: Colors.white)),
        ]))),
      ]),
    );
  }
}
