import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/url_resolver.dart';

class DebugNetworkDiagnosticsScreen extends StatefulWidget {
  const DebugNetworkDiagnosticsScreen({super.key});

  @override
  State<DebugNetworkDiagnosticsScreen> createState() =>
      _DebugNetworkDiagnosticsScreenState();
}

class _DebugNetworkDiagnosticsScreenState
    extends State<DebugNetworkDiagnosticsScreen> {
  final List<String> _logs = <String>[];
  bool _isRunningHealthTest = false;
  bool _isRunningImageTest = false;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Network diagnostics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API_BASE_URL: ${AppConfig.activeApiBaseUrl}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'apiPrefix: ${AppConfig.activeApiPrefix}',
              style: const TextStyle(color: Color(0xFF4E6374)),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunningHealthTest ? null : _testHealth,
                  icon: _isRunningHealthTest
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.health_and_safety),
                  label: const Text('Test API /health'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunningImageTest ? null : _testImageUrl,
                  icon: _isRunningImageTest
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.image_search),
                  label: const Text('Test Image URL'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(_logs.clear);
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear logs'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Diagnostics output',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F8FC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD3E2EE)),
                ),
                child: _logs.isEmpty
                    ? const Text('No diagnostic logs yet.')
                    : SingleChildScrollView(
                        child: SelectableText(
                          _logs.join('\n'),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Color(0xFF17354B),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testHealth() async {
    setState(() => _isRunningHealthTest = true);
    _appendLog('--- Test API /health ---');

    final client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Accept': 'application/json'},
      ),
    );

    try {
      final url = '${AppConfig.activeApiPrefix}/health';
      _appendLog('Request: GET $url');
      final response = await client.get(url);
      _appendLog('Status: ${response.statusCode}');
      _appendLog('Body: ${response.data}');
    } catch (error) {
      _appendLog('Error: $error');
    } finally {
      if (mounted) {
        setState(() => _isRunningHealthTest = false);
      }
    }
  }

  Future<void> _testImageUrl() async {
    setState(() => _isRunningImageTest = true);
    _appendLog('--- Test Image URL ---');

    final client = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Accept': 'application/json'},
      ),
    );

    try {
      final catalogUrl =
          '${AppConfig.activeApiPrefix}/catalog/books?per_page=3';
      _appendLog('Request: GET $catalogUrl');
      final catalogResponse = await client.get(catalogUrl);
      _appendLog('Catalog status: ${catalogResponse.statusCode}');

      final list = (catalogResponse.data['data'] as List<dynamic>? ?? const []);
      if (list.isEmpty) {
        _appendLog('No books returned from catalog.');
        return;
      }

      final firstBook = list.first as Map<String, dynamic>;
      final rawImage = firstBook['image_url'] as String?;
      final rawPath = firstBook['image_path'] as String?;
      final fallbackImage = firstBook['cover_image'] as String?;
      _appendLog(
        'Raw image fields: image_url=$rawImage image_path=$rawPath cover_image=$fallbackImage',
      );

      final resolvedUrl = resolveImageUrl(rawImage ?? rawPath ?? fallbackImage);
      _appendLog('Resolved image URL: $resolvedUrl');

      if (resolvedUrl == null) {
        _appendLog('Resolved URL is null.');
        return;
      }

      final imageResponse = await client.get<List<int>>(
        resolvedUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final byteLength = imageResponse.data?.length ?? 0;
      _appendLog('Image status: ${imageResponse.statusCode}');
      _appendLog('Image bytes: $byteLength');
    } catch (error) {
      _appendLog('Error: $error');
    } finally {
      if (mounted) {
        setState(() => _isRunningImageTest = false);
      }
    }
  }

  void _appendLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    setState(() {
      _logs.add('[$timestamp] $message');
    });
  }
}
