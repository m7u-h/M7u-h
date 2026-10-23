import 'dart:convert';
import 'dart:io';
import 'package:media_link_generator/media_link_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/link_item.dart';

class LinkService {
  static const String _historyKey = 'link_history';

  // توليد التوكن (مرة واحدة فقط لكل مستخدم)
  static Future<void> generateToken(String email) async {
    await MediaLink().generateAndSetToken(email, shouldPrint: true);
  }

  // رفع الملف وإرجاع الرابط المباشر
  static Future<String?> uploadFile(File file, String fileName) async {
    try {
      final result = await MediaLink().uploadFile(
        file,
        folderName: 'converted_links',
        isSecret: false,
        fromDeviceName: 'my_phone',
        shouldPrint: true,
      );
      if (result != null) {
        return result.link;
      }
    } catch (e) {
      print('Upload error: $e');
    }
    return null;
  }

  // حفظ رابط جديد في السجل
  static Future<void> saveToHistory(LinkItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_historyKey) ?? [];
    existing.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_historyKey, existing);
  }

  // قراءة كل السجل (الأحدث أولاً)
  static Future<List<LinkItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_historyKey);
    if (raw == null) return [];
    return raw
        .map((e) => LinkItem.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  // حذف السجل بالكامل
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
