import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/link_item.dart';

class LinkService {
  static const String _historyKey = 'link_history';

  static Future<void> generateToken(String email) async {}

  static Future<String> uploadFile(Uint8List fileBytes, String fileName) async {
    // قائمة بالسيرفرات الجديدة التي من المرجح أن تعمل
    // 1. DirectLink API
    String? result = await _uploadToDirectLink(fileBytes, fileName);
    if (result != null) return result;

    // 2. FileUp API
    result = await _uploadToFileUp(fileBytes, fileName);
    if (result != null) return result;

    // 3. tfLink API
    result = await _uploadToTfLink(fileBytes, fileName);
    if (result != null) return result;

    // 4. FileToUrl
    result = await _uploadToFileToUrl(fileBytes, fileName);
    if (result != null) return result;

    // السيرفرات القديمة كخيارات احتياطية
    // 5. catbox.moe
    result = await _uploadToCatbox(fileBytes, fileName);
    if (result != null) return result;

    // 6. 0x0.st
    result = await _uploadTo0x0(fileBytes, fileName);
    if (result != null) return result;

    // 7. tmpfiles.org
    result = await _uploadToTmpfiles(fileBytes, fileName);
    if (result != null) return result;

    return 'هەموو سێرڤەرەکان شکستیان هێنا. تکایە پەیوەندی ئینتەرنێتەکەت بپشکنە یان ڕێکخستنەکانی DNS بگۆڕە.';
  }

  // --- دوال الرفع للسيرفرات الجديدة ---

  static Future<String?> _uploadToDirectLink(Uint8List fileBytes, String fileName) async {
    try {
      // استخدام النسخة التجريبية من DirectLink
      var uri = Uri.parse('https://www.dlink666.com/api/upload?name=$fileName');
      var request = http.Request('PUT', uri);
      request.bodyBytes = fileBytes;
      
      var streamedResponse = await request.send().timeout(const Duration(minutes: 3));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 && response.body.startsWith('http')) {
        return response.body.trim();
      }
    } catch (e) { print('DirectLink failed: $e'); }
    return null;
  }

  static Future<String?> _uploadToFileUp(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://upload.sinasnp.com/api/public/upload'));
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        if (json['url'] != null) return json['url'];
      }
    } catch (e) { print('FileUp failed: $e'); }
    return null;
  }

  static Future<String?> _uploadToTfLink(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://tflink.net/api/upload'));
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        if (json['url'] != null) return json['url'];
      }
    } catch (e) { print('tfLink failed: $e'); }
    return null;
  }

  static Future<String?> _uploadToFileToUrl(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://filetourl.org/api/upload'));
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        if (json['url'] != null) return json['url'];
      }
    } catch (e) { print('FileToUrl failed: $e'); }
    return null;
  }

  // --- دوال الرفع للسيرفرات القديمة (للاحتياط) ---

  static Future<String?> _uploadToCatbox(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://catbox.moe/user/api.php'));
      request.fields['reqtype'] = 'fileupload';
      request.headers['User-Agent'] = 'Mozilla/5.0';
      request.files.add(http.MultipartFile.fromBytes('fileToUpload', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200 && responseData.startsWith('http')) return responseData.trim();
    } catch (e) { print('Catbox failed: $e'); }
    return null;
  }

  static Future<String?> _uploadTo0x0(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://0x0.st'));
      request.headers['User-Agent'] = 'Mozilla/5.0';
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200 && responseData.startsWith('http')) return responseData.trim();
    } catch (e) { print('0x0.st failed: $e'); }
    return null;
  }

  static Future<String?> _uploadToTmpfiles(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://tmpfiles.org/api/v1/upload'));
      request.headers['User-Agent'] = 'Mozilla/5.0';
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        if (json['data'] != null && json['data']['url'] != null) {
          String pageUrl = json['data']['url'];
          return pageUrl.replaceFirst('tmpfiles.org/', 'tmpfiles.org/dl/');
        }
      }
    } catch (e) { print('Tmpfiles failed: $e'); }
    return null;
  }

  // --- دوال السجل (بدون تغيير) ---
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
