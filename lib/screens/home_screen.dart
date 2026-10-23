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
  String _status = 'ئامادەیە بۆ گۆڕین بۆ لینک';
  String? _downloadLink;
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    setState(() {
      _isUploading = true;
      _status = 'فایلەکە دەگوازرێتەوە... تکایە چاوەڕێ بکە';
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
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload, size: 80, color: Colors.blue),
                ),
                const SizedBox(height: 30),
                const Text(
                  'فایلێک هەڵبژێرە',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, 
                    color: _downloadLink != null ? Colors.green : Colors.grey,
                    fontWeight: _downloadLink != null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 40),
                
                if (_isUploading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _pickAndUpload,
                      icon: const Icon(Icons.link, color: Colors.white),
                      label: const Text(
                        'گۆڕین بۆ لینک',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  
                if (_downloadLink != null) ...[
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'لینکی ڕاستەوخۆ:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _downloadLink!,
                          style: const TextStyle(color: Colors.blue, fontSize: 14),
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
