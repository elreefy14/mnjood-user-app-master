import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// إدارة معرفات الضيوف (Guest IDs)
/// يستخدم لتتبع سلة التسوق للمستخدمين غير المسجلين
class GuestManager {
  static const String _guestIdKey = 'guest_id';

  /// توليد معرف ضيف جديد فريد
  /// يتكون من timestamp + رقم عشوائي
  static String generateGuestId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(999999);
    return '$timestamp$randomNumber';
  }

  /// الحصول على معرف الضيف الحالي أو إنشاء واحد جديد
  ///
  /// يستخدم عند:
  /// - فتح التطبيق لأول مرة
  /// - قبل أي عملية على السلة (إضافة/تحديث/حذف)
  /// - جلب عناصر السلة
  static Future<String> getOrCreateGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    String? guestId = prefs.getString(_guestIdKey);

    if (guestId == null || guestId.isEmpty) {
      guestId = generateGuestId();
      await prefs.setString(_guestIdKey, guestId);
    }

    return guestId;
  }

  /// حذف معرف الضيف من الذاكرة المحلية
  ///
  /// ⚠️ مهم: يجب استدعاء هذه الدالة بعد تسجيل الدخول بنجاح
  /// لأن المستخدم لم يعد ضيفاً
  static Future<void> clearGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestIdKey);
  }

  /// التحقق من وجود معرف ضيف في الذاكرة المحلية
  ///
  /// Returns: true إذا كان المستخدم ضيفاً (غير مسجل)
  static Future<bool> hasGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_guestIdKey);
  }

  /// الحصول على معرف الضيف بدون إنشاء واحد جديد
  ///
  /// Returns: معرف الضيف أو null إذا لم يكن موجوداً
  static Future<String?> getGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_guestIdKey);
  }
}
