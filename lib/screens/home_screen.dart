import 'dart:io';
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
  String _status = 'فایلێک هەڵبژێرە بۆ دەستپێکردن';
  String? _downloadLink;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // ⚠️ فعّل هذا السطر مرة واحدة فقط في أول تشغيل، ثم احذفه
    // LinkService.generateToken('your_email@gmail.com');
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    setState(() {
      _isUploading = true;
      _status = 'فایلەکە دەگوازرێتەوە...';
      _downloadLink = null;
    });

    final link = await LinkService.uploadFile(file, fileName);

    if (link != null) {
      final item = LinkItem(
        fileName: fileName,
        url: link,
        createdAt: DateTime.now(),
      );
      await LinkService.saveToHistory(item);

      setState(() {
        _downloadLink = link;
        _status = 'سەرکەوتوو بوو! لینکی ڕاستەوخۆ:';
      });
    } else {
      setState(() {
        _status = 'هەڵەیەک ڕوویدا. تکایە دووبارە هەوڵ بدەرەوە.';
      });
    }

    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(
        onHistoryTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.upload_file, size: 90, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'فایلێک هەڵبژێرە',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ئامادەیە بۆ گۆڕین بۆ لینک',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (_isUploading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: _pickAndUpload,
                    icon: const Icon(Icons.link),
                    label: const Text(
                      'گۆڕین بۆ لینک',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                if (_downloadLink != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'لینکی ڕاستەوخۆ:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _downloadLink!,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
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
