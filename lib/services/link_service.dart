import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/link_item.dart';

class LinkService {
  static const String _historyKey = 'link_history';

  static Future<void> generateToken(String email) async {}

  // تغيير نوع الاستقبال إلى Stream لتفادي انهيار الذاكرة (Out of Memory)
  static Future<String> uploadFile(Stream<List<int>> stream, int length, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
      request.fields['reqtype'] = 'fileupload';
      request.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36';
      
      request.files.add(http.MultipartFile(
        'fileToUpload',
        stream,
        length,
        filename: fileName,
      ));

      var response = await request.send().timeout(const Duration(minutes: 10));
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200 && responseData.startsWith('http')) {
        return responseData.trim(); // الرابط المباشر
      } else {
        return 'هەڵەی سێرڤەر: ${response.statusCode} - $responseData';
      }
    } catch (e) {
      return 'هەڵە لە پەیوەندی: $e';
    }
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
