import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'settings_providers.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});
  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  final _host = TextEditingController();
  final _port = TextEditingController(text: '9100');
  bool _enabled = false;
  bool _loaded = false;

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  void _hydrate(PrinterConfig c) {
    if (_loaded) return;
    _loaded = true;
    _enabled = c.enabled;
    _host.text = c.host;
    _port.text = c.port.toString();
  }

  PrinterConfig get _current => PrinterConfig(
        enabled: _enabled,
        host: _host.text.trim(),
        port: int.tryParse(_port.text.trim()) ?? 9100,
      );

  Future<void> _save(AppLocalizations l) async {
    await ref.read(printerSettingsControllerProvider.notifier).save(_current);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.savedOk)));
    }
  }

  Future<void> _testPrint(AppLocalizations l) async {
    final cfg = _current;
    if (!cfg.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.printerNotConfigured)));
      return;
    }
    final printer = TcpReceiptPrinter(host: cfg.host, port: cfg.port);
    final bytes = const EscPosEncoder().encode(ReceiptData(
      shopName: 'DukanPro',
      number: l.testPrint,
      dateTime: DateTime.now(),
      lines: const [ReceiptLineData(name: 'TEST', qtyLabel: '×1', lineTotalMinor: 0)],
      subtotalMinor: 0, totalMinor: 0, paidMinor: 0, changeMinor: 0,
    ));
    try {
      await printer.printRaw(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.printSucceeded)));
      }
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.printFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(printerSettingsControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.printerSettings)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (config) {
          _hydrate(config);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text(l.enablePrinting),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _host,
                enabled: _enabled,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: l.printerHost, hintText: '192.168.1.50', border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _port,
                enabled: _enabled,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l.printerPort, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _testPrint(l),
                      icon: const Icon(Icons.print_outlined),
                      label: Text(l.testPrint),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _save(l),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(l.save),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
