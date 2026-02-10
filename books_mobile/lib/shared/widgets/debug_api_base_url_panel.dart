import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../screens/debug_network_diagnostics_screen.dart';

class DebugApiBaseUrlPanel extends StatelessWidget {
  const DebugApiBaseUrlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return ValueListenableBuilder<String>(
      valueListenable: AppConfig.debugApiBaseUrlListenable,
      builder: (context, activeBaseUrl, _) {
        final options = <String>{
          activeBaseUrl,
          ...AppConfig.debugApiBaseCandidates,
        }.toList();

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F8FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD4E4F1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Developer API endpoint',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF20445F),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Current: $activeBaseUrl',
                style: const TextStyle(fontSize: 12, color: Color(0xFF3E5A70)),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: activeBaseUrl,
                decoration: const InputDecoration(
                  labelText: 'Switch API base URL',
                ),
                items: options
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  AppConfig.setDebugApiBaseUrl(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('API base URL set to $value')),
                  );
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DebugNetworkDiagnosticsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.science),
                  label: const Text('Open diagnostics'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
