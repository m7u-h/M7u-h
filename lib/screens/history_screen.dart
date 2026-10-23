import 'package:flutter/material.dart';
import '../models/link_item.dart';
import '../services/link_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<LinkItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await LinkService.getHistory();
    setState(() {
      _history = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داگرتەکان', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0B1114),
        iconTheme: const IconThemeData(color: Color(0xFF00E5FF)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00E5FF)))
          : _history.isEmpty
              ? const Center(child: Text('هیچ لینکێک نییە', style: TextStyle(color: Colors.grey, fontSize: 18)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151E23),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.link, color: Color(0xFF00E5FF)),
                        title: Text(item.fileName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: SelectableText(item.url, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                    );
                  },
                ),
    );
  }
}
