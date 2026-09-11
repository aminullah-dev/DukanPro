import 'dart:convert';

import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers.dart';

/// Device-local thermal-printer configuration (ESC/POS over TCP).
class PrinterConfig {
  const PrinterConfig({this.enabled = false, this.host = '', this.port = 9100});
  final bool enabled;
  final String host;
  final int port;

  bool get isReady => enabled && host.trim().isNotEmpty;

  PrinterConfig copyWith({bool? enabled, String? host, int? port}) => PrinterConfig(
        enabled: enabled ?? this.enabled,
        host: host ?? this.host,
        port: port ?? this.port,
      );

  Map<String, Object?> toJson() => {'enabled': enabled, 'host': host, 'port': port};

  factory PrinterConfig.fromJson(Map<String, Object?> j) => PrinterConfig(
        enabled: (j['enabled'] as bool?) ?? false,
        host: (j['host'] as String?) ?? '',
        port: (j['port'] as num?)?.toInt() ?? 9100,
      );
}

const _kPrinterKey = 'printer';

final settingsStoreProvider =
    Provider<SettingsStore>((ref) => SettingsStore(ref.watch(databaseProvider)));

/// Loads and persists the printer configuration.
class PrinterSettingsController extends AsyncNotifier<PrinterConfig> {
  SettingsStore get _store => ref.read(settingsStoreProvider);

  @override
  Future<PrinterConfig> build() async {
    final raw = await _store.get(_kPrinterKey);
    if (raw == null) return const PrinterConfig();
    try {
      return PrinterConfig.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());
    } on Object {
      return const PrinterConfig();
    }
  }

  Future<void> save(PrinterConfig config) async {
    await _store.set(_kPrinterKey, jsonEncode(config.toJson()));
    state = AsyncData(config);
  }
}

final printerSettingsControllerProvider =
    AsyncNotifierProvider<PrinterSettingsController, PrinterConfig>(PrinterSettingsController.new);

/// The active receipt printer, or null when none is configured (on-screen
/// receipt only). Rebuilds when the configuration changes.
final receiptPrinterProvider = Provider<ReceiptPrinter?>((ref) {
  final config = ref.watch(printerSettingsControllerProvider).asData?.value;
  if (config == null || !config.isReady) return null;
  return TcpReceiptPrinter(host: config.host.trim(), port: config.port);
});
