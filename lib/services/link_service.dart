import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/link_item.dart';

class LinkService {
  static const String _historyKey = 'link_history';

  static Future<void> generateToken(String email) async {}

  static Future<String?> uploadFile(File file, String fileName) async {
    try {
      // 1. قراءة الملف كبيانات (تضمن الاشتغال على كل الأجهزة)
      List<int> fileBytes = await file.readAsBytes();

      var request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
      request.fields['reqtype'] = 'fileupload';
      
      // 2. إرسال البيانات بدل المسار
      request.files.add(http.MultipartFile.fromBytes(
        'fileToUpload',
        fileBytes,
        filename: fileName,
      ));

      var response = await request.send().timeout(const Duration(minutes: 2));
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 && responseData.startsWith('http')) {
        return responseData.trim(); // الرابط المباشر
      } else {
        print('Server Error: $responseData');
      }
    } catch (e) {
      print('Upload exception: $e');
    }
    return null;
  }

  static Future<void> saveToHistory(LinkItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existing = prefs.getStringList(_historyKey) ?? [];
    existing.add(jsonEncode(item.toJson()));
    await prefs.setStringList(_historyKey, existing);
  }

  static Future<List<LinkItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_historyKey);
    if (raw == null) return [];
    return raw.map((e) => LinkItem.fromJson(jsonDecode(e))).toList().reversed.toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
