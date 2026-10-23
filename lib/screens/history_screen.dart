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

  Future<void> _clearHistory() async {
    await LinkService.clearHistory();
    setState(() => _history = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حافیزە'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(
                  child: Text(
                    'هیچ لینکێک نییە',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.insert_drive_file,
                            color: Colors.blue),
                        title: Text(
                          item.fileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: SelectableText(
                          item.url,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(Icons.link, color: Colors.grey),
                      ),
                    );
                  },
                ),
    );
  }
}
