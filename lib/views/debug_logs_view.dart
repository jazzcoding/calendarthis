import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/logging_service.dart';
import '../constants/app_theme.dart';

class DebugLogsView extends StatefulWidget {
  const DebugLogsView({super.key});

  @override
  State<DebugLogsView> createState() => _DebugLogsViewState();
}

class _DebugLogsViewState extends State<DebugLogsView> {
  final LoggingService _loggingService = LoggingService();
  List<String> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
    });

    final logs = await _loggingService.getLogs();
    
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  Future<void> _clearLogs() async {
    await _loggingService.clearLogs();
    await _loadLogs();
  }

  Future<void> _copyLogs() async {
    final text = _logs.join('\n');
    await Clipboard.setData(ClipboardData(text: text));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logs copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
            tooltip: 'Refresh logs',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _logs.isEmpty ? null : _copyLogs,
            tooltip: 'Copy logs',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _logs.isEmpty ? null : _clearLogs,
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No logs available',
                        style: AppTheme.subtitle1Style.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[_logs.length - 1 - index]; // Reverse order
                    
                    // Parse log entry
                    String timestamp = '';
                    String tag = '';
                    String message = log;
                    
                    final regex = RegExp(r'^(.*?)\s+\[(.*?)\]\s+(.*)$');
                    final match = regex.firstMatch(log);
                    
                    if (match != null) {
                      timestamp = match.group(1) ?? '';
                      tag = match.group(2) ?? '';
                      message = match.group(3) ?? '';
                    }
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        title: Text(
                          message,
                          style: AppTheme.body1Style,
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTagColor(tag),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: AppTheme.captionStyle.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                timestamp,
                                style: AppTheme.captionStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Log Details'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Timestamp: $timestamp'),
                                    const SizedBox(height: 8),
                                    Text('Tag: $tag'),
                                    const SizedBox(height: 8),
                                    const Text('Message:'),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(message),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: log));
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Log copied to clipboard'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: const Text('Copy'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
  
  Color _getTagColor(String tag) {
    switch (tag) {
      case 'DB':
        return Colors.blue;
      case 'API':
        return Colors.purple;
      case 'ERROR':
        return Colors.red;
      case 'UI':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
