import 'dart:convert';

import 'package:dukan_core/dukan_core.dart' show Permission, PermissionDeniedError, ValidationError;
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/providers.dart';
import '../auth/session.dart';

/// Device-local thermal-printer configuration (ESC/POS over TCP).
class PrinterConfig {
  const PrinterConfig({this.enabled = false, this.host = '', this.port = 9100, this.paperMm = 80});
  final bool enabled;
  final String host;
  final int port;

  /// The roll's width, 58 or 80 mm: the receipt is drawn to fit it.
  final int paperMm;

  bool get isReady => enabled && host.trim().isNotEmpty;

  PrinterConfig copyWith({bool? enabled, String? host, int? port, int? paperMm}) => PrinterConfig(
        enabled: enabled ?? this.enabled,
        host: host ?? this.host,
        port: port ?? this.port,
        paperMm: paperMm ?? this.paperMm,
      );

  Map<String, Object?> toJson() => {'enabled': enabled, 'host': host, 'port': port, 'paper_mm': paperMm};

  factory PrinterConfig.fromJson(Map<String, Object?> j) => PrinterConfig(
        enabled: (j['enabled'] as bool?) ?? false,
        host: (j['host'] as String?) ?? '',
        port: (j['port'] as num?)?.toInt() ?? 9100,
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

/// The active receipt printer, or null when none is configured (on-screen
/// receipt only). Rebuilds when the configuration changes.
final receiptPrinterProvider = Provider<ReceiptPrinter?>((ref) {
  final config = ref.watch(printerSettingsControllerProvider).asData?.value;
  if (config == null || !config.isReady) return null;
  return TcpReceiptPrinter(host: config.host.trim(), port: config.port);
});

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
