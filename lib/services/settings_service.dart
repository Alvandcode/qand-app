import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

/// تنظیمات قابل ویرایش توسط مدیر از داخل اپ:
/// شماره کارت + صاحب حساب + لینک زرین‌پال
/// بعدا به جدول app_settings در سوپابیس وصل می‌شود؛ فعلا لوکال.
class SettingsService {
  static const _kCard = 'set_card';
  static const _kOwner = 'set_owner';
  static const _kZarin = 'set_zarin';

  Future<Map<String, String>> load() async {
    final p = await SharedPreferences.getInstance();
    return {
      'card': p.getString(_kCard) ?? AppConfig.defaultCardNumber,
      'owner': p.getString(_kOwner) ?? AppConfig.defaultCardOwner,
      'zarin': p.getString(_kZarin) ?? AppConfig.defaultZarinpalLink,
    };
  }

  Future<void> save({required String card, required String owner, required String zarin}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kCard, card);
    await p.setString(_kOwner, owner);
    await p.setString(_kZarin, zarin);
  }
}
