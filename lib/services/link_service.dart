import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/link_item.dart';

class LinkService {
  static const String _historyKey = 'link_history';

  static Future<void> generateToken(String email) async {}

  static Future<String> uploadFile(Uint8List fileBytes, String fileName) async {
    // 1. المحاولة الأولى: سيرفر file.io
    String? result = await _uploadToFileIo(fileBytes, fileName);
    if (result != null && result.startsWith('http')) return result;

    // 2. المحاولة الثانية: سيرفر gofile.io
    result = await _uploadToGofile(fileBytes, fileName);
    if (result != null && result.startsWith('http')) return result;

    // 3. المحاولة الثالثة: سيرفر 0x0.st
    result = await _uploadTo0x0(fileBytes, fileName);
    if (result != null && result.startsWith('http')) return result;

    // 4. المحاولة الرابعة: سيرفر tmpfiles.org
    result = await _uploadToTmpfiles(fileBytes, fileName);
    if (result != null && result.startsWith('http')) return result;

    return 'هەموو سێرڤەرەکان شکستیان هێنا. تکایە پەیوەندی ئینتەرنێتەکەت بپشکنە یان ڤی پی ئێن (VPN) بکوژێنەوە.';
  }

  static Future<String?> _uploadToFileIo(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://file.io'));
      request.headers['User-Agent'] = 'Mozilla/5.0';
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        if (json['link'] != null) return json['link'];
      }
    } catch (e) { print('File.io failed: $e'); }
    return null;
  }

  static Future<String?> _uploadToGofile(Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://upload.gofile.io/uploadfile'));
      request.headers['User-Agent'] = 'Mozilla/5.0';
      request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      
      var response = await request.send().timeout(const Duration(minutes: 3));
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        var json = jsonDecode(responseData);
        if (json['data'] != null && json['data']['downloadPage'] != null) {
          return json['data']['downloadPage'];
        }
      }
    } catch (e) { print('Gofile failed: $e'); }
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
