import 'dart:convert';

import 'package:dukan_core/dukan_core.dart' show Permission, PermissionDeniedError, ValidationError;
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/plugin_printers.dart';
import '../auth/providers.dart';
import '../auth/session.dart';

/// Device-local receipt-printer configuration: how the printer is reached (a
/// network address, or a Bluetooth, BLE or USB printer a search found) and the
/// roll's width.
class PrinterConfig {
  const PrinterConfig({
    this.enabled = false,
    this.transport = PrinterTransport.tcp,
    this.host = '',
    this.port = 9100,
    this.deviceId = '',
    this.deviceName = '',
    this.paperMm = 80,
  });
  final bool enabled;
  final PrinterTransport transport;

  /// A network printer's address.
  final String host;
  final int port;

  /// A Bluetooth, BLE or USB printer: its address or id, and the name it gave.
  final String deviceId;
  final String deviceName;

  /// The roll's width, 58 or 80 mm: the receipt is drawn to fit it.
  final int paperMm;

  bool get isReady =>
      enabled && (transport == PrinterTransport.tcp ? host.trim().isNotEmpty : deviceId.isNotEmpty);

  PrinterConfig copyWith({
    bool? enabled,
    PrinterTransport? transport,
    String? host,
    int? port,
    String? deviceId,
    String? deviceName,
    int? paperMm,
  }) =>
      PrinterConfig(
        enabled: enabled ?? this.enabled,
        transport: transport ?? this.transport,
        host: host ?? this.host,
        port: port ?? this.port,
        deviceId: deviceId ?? this.deviceId,
        deviceName: deviceName ?? this.deviceName,
        paperMm: paperMm ?? this.paperMm,
      );

  Map<String, Object?> toJson() => {
        'enabled': enabled,
        'transport': transport.name,
        'host': host,
        'port': port,
        'device_id': deviceId,
        'device_name': deviceName,
        'paper_mm': paperMm,
      };

  /// A configuration saved before Bluetooth and USB printers names no transport:
  /// it was a network printer, and still is.
  factory PrinterConfig.fromJson(Map<String, Object?> j) => PrinterConfig(
        enabled: (j['enabled'] as bool?) ?? false,
        transport: PrinterTransport.values.asNameMap()[j['transport']] ?? PrinterTransport.tcp,
        host: (j['host'] as String?) ?? '',
        port: (j['port'] as num?)?.toInt() ?? 9100,
        deviceId: (j['device_id'] as String?) ?? '',
        deviceName: (j['device_name'] as String?) ?? '',
        paperMm: (j['paper_mm'] as num?)?.toInt() == 58 ? 58 : 80,
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

/// The ways this device can reach a printer (tests choose their own).
final printerTransportsProvider = Provider<List<PrinterTransport>>((ref) => printerTransportsForPlatform());

/// Searches for Bluetooth, BLE and USB printers (tests put a fake here).
final printerFinderProvider = Provider<PrinterFinder>((ref) => const PluginPrinterFinder());

/// Opens one print job's connection to a Bluetooth, BLE or USB printer (tests
/// put a fake here).
final printerLinkProvider = Provider<PrinterLink Function(PrinterConfig)>(
  (ref) => (c) => PluginPrinterLink(transport: c.transport, id: c.deviceId, name: c.deviceName),
);

/// The printer a configuration names, saved or not: the till's receipts and the
/// settings' test print go through the same one.
final printerForProvider = Provider<ReceiptPrinter Function(PrinterConfig)>((ref) {
  final link = ref.watch(printerLinkProvider);
  return (c) => switch (c.transport) {
        PrinterTransport.tcp => TcpReceiptPrinter(host: c.host.trim(), port: c.port),
        _ => LinkReceiptPrinter(transport: c.transport, link: () => link(c)),
      };
});

/// The active receipt printer, or null when none is configured (on-screen
/// receipt only). Rebuilds when the configuration changes.
final receiptPrinterProvider = Provider<ReceiptPrinter?>((ref) {
  final config = ref.watch(printerSettingsControllerProvider).asData?.value;
  if (config == null || !config.isReady) return null;
  return ref.watch(printerForProvider)(config);
});

/// How long a print job may take before the till stops waiting. A Bluetooth,
/// BLE or USB printer connects afresh for every job, and BLE sends a picture
/// receipt in small pieces, so they get longer than a network printer.
Duration printJobTimeout(PrinterTransport transport) =>
    transport == PrinterTransport.tcp ? const Duration(seconds: 10) : const Duration(seconds: 30);

/// How soon an idle app locks, in minutes: a setting of this device, chosen by
/// an owner or a manager (settings.manage). A till several people share wants
/// it short, a one-person shop longer; until someone chooses, it is 10 minutes.
const kIdleLockChoices = [1, 2, 5, 10, 15, 30];
const kDefaultIdleLockMinutes = 10;
const idleLockSettingKey = 'idle_lock_minutes';

class IdleLockController extends AsyncNotifier<int> {
  SettingsStore get _store => ref.read(settingsStoreProvider);

  @override
  Future<int> build() async {
    final saved = int.tryParse(await _store.get(idleLockSettingKey) ?? '');
    return kIdleLockChoices.contains(saved) ? saved! : kDefaultIdleLockMinutes;
  }

  /// Keeps [minutes] for this device. The screen offers the choice only to an
  /// owner or a manager; this holds whoever calls it.
  Future<void> save(int minutes) async {
    if (!(ref.read(sessionActorProvider)?.can(Permission.settingsManage) ?? false)) {
      throw PermissionDeniedError('ACCESS_DENIED', {'permission': Permission.settingsManage.code});
    }
    if (!kIdleLockChoices.contains(minutes)) {
      throw ValidationError('IDLE_LOCK_INVALID', {'minutes': minutes});
    }
    await _store.set(idleLockSettingKey, '$minutes');
    state = AsyncData(minutes);
  }
}

final idleLockProvider = AsyncNotifierProvider<IdleLockController, int>(IdleLockController.new);
