import 'package:shared_preferences/shared_preferences.dart';

/// سرویس احراز هویت ساده:
/// - حالت آفلاین/دمو: نام‌کاربری+رمز در SharedPreferences
/// - وقتی سوپابیس وصل شد: همین نام‌کاربری به username@qand.local مپ می‌شود (در auth_service_supabase)
/// نقش مدیر: username == admin
class AuthService {
  static const _kUser = 'qand_user';
  static const _kRole = 'qand_role';

  Future<bool> register(String username, String password) async {
    final p = await SharedPreferences.getInstance();
    final key = 'user_$username';
    if (p.containsKey(key)) return false;
    await p.setString(key, password);
    await p.setString(_kUser, username);
    await p.setString(_kRole, username == 'admin' ? 'admin' : 'user');
    return true;
  }

  Future<bool> login(String username, String password) async {
    final p = await SharedPreferences.getInstance();
    // ادمین پیش‌فرض: admin / 1234 (اولین ورود؛ بعدا از پنل عوض کن)
    if (username == 'admin' && password == '1234' && !p.containsKey('user_admin')) {
      await p.setString('user_admin', '1234');
    }
    final saved = p.getString('user_$username');
    if (saved == null || saved != password) return false;
    await p.setString(_kUser, username);
    await p.setString(_kRole, username == 'admin' ? 'admin' : 'user');
    return true;
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kUser);
    await p.remove(_kRole);
  }

  Future<String?> currentUser() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kUser);
  }

  Future<bool> isAdmin() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kRole) == 'admin';
  }
}
