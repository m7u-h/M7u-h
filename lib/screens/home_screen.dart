import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/link_item.dart';
import '../services/link_service.dart';
import '../widgets/top_bar.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _status = 'تەنها فایلەکەت هەڵبژێرە بۆ گۆڕین بۆ لینک';
  String? _downloadLink;
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null) return;

    final file = result.files.single;
    final fileBytes = file.bytes;
    final originalFileName = file.name;

    if (fileBytes == null) {
      setState(() => _status = 'هەڵە لە خوێندنەوەی فایلەکە. تکایە فایلێکی تر هەڵبژێرە.');
      return;
    }

    if (fileBytes.length > 200 * 1024 * 1024) {
      setState(() => _status = 'فایلەکە زۆر گەورەیە! سنووری سێرڤەر 200 MBە.');
      return;
    }

    // إضافة حقوقك (m7uh) على اسم الملف
    final fileName = 'm7uh_$originalFileName';

    setState(() {
      _isUploading = true;
      _status = 'فایلەکە دەگوازرێتەوە... تکایە چاوەڕێ بکە';
      _downloadLink = null;
    });

    final linkResult = await LinkService.uploadFile(fileBytes, fileName);

    if (linkResult.startsWith('http')) {
      final item = LinkItem(fileName: fileName, url: linkResult, createdAt: DateTime.now());
      await LinkService.saveToHistory(item);

      setState(() {
        _downloadLink = linkResult;
        _status = 'سەرکەوتوو بوو! لینکی ڕاستەوخۆ:';
      });
    } else {
      setState(() => _status = linkResult); // تظهر رسالة الخطأ الحقيقية
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onHistoryTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'app m7u-h',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF00E5FF),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, 
                    color: _downloadLink != null ? Color(0xFF00E5FF) : Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151E23),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.upload_file, color: Colors.grey),
                      SizedBox(width: 10),
                      Text('هەر فایلێک هەڵبژێرە (ڤیدیۆ، وێنە، دەنگ، ZIP)...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                if (_isUploading)
                  const CircularProgressIndicator(color: Color(0xFF00E5FF))
                else
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _pickAndUpload,
                      icon: const Icon(Icons.download, color: Colors.black, size: 28),
                      label: const Text(
                        'گۆڕین بۆ لینک',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 10,
                        shadowColor: const Color(0xFF00E5FF).withOpacity(0.5),
                      ),
                    ),
                  ),
                  
                if (_downloadLink != null) ...[
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151E23),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('لینکی ڕاستەوخۆ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        SelectableText(
                          _downloadLink!,
                          style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
