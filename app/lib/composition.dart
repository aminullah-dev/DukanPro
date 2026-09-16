import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root — the one place a concrete class meets an interface.
/// Dependencies point inward: the app wires implementations (dukan_data) to the
/// ports declared in dukan_core, and to sync/hardware ports implemented later.

/// The UI locale chosen last on this device (main reads it before the first
/// frame), or null on a new install.
final savedLocaleProvider = Provider<Locale?>((ref) => null);

/// Saves a chosen UI locale on the device (main wires it to the settings).
final saveLocaleProvider = Provider<void Function(Locale)>((ref) => (_) {});

/// Active UI locale: the one chosen last on this device, else Dari (fa-AF).
/// Switchable at any time, the sign-in screen included.
final class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => ref.watch(savedLocaleProvider) ?? const Locale('fa', 'AF');

  void set(Locale locale) {
    state = locale;
    ref.read(saveLocaleProvider)(locale);
  }
}

/// The device setting that holds the chosen locale, as a tag ('fa_AF', 'ps').
const localeSettingKey = 'ui.locale';

String localeTag(Locale locale) =>
    locale.countryCode == null ? locale.languageCode : '${locale.languageCode}_${locale.countryCode}';

/// The supported locale a saved tag names, or null (none saved, or no longer offered).
Locale? localeFromTag(String? tag, List<Locale> supported) {
  for (final locale in supported) {
    if (localeTag(locale) == tag) return locale;
  }
  return null;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

/// How this install works, chosen once when the shop is first set up.
enum AppMode {
  /// A shop with a server behind it: the server keeps the staff, the branches
  /// and the audit trail, every device syncs to it, and it is what confirms a
  /// user before a device's offline window runs out.
  server,

  /// One device is the whole shop: it keeps its own owner account and its own
  /// books, and never calls a server. Nothing to install, nothing to reach.
  standalone,
}

/// The mode saved on this device (main reads it before the first frame), or
/// null on a device where no shop has been set up yet.
final savedAppModeProvider = Provider<AppMode?>((ref) => null);

/// Saves the chosen mode on the device (main wires it to the settings).
final saveAppModeProvider = Provider<void Function(AppMode)>((ref) => (_) {});

/// The device setting that holds the mode, as a name ('server', 'standalone').
const appModeSettingKey = 'app.mode';

AppMode appModeFromTag(String? tag) =>
    tag == AppMode.standalone.name ? AppMode.standalone : AppMode.server;

/// The mode this install runs in: the one saved on this device, else a shop
/// with a server. Set once, by setting the shop up.
final class AppModeNotifier extends Notifier<AppMode> {
  @override
  AppMode build() => ref.watch(savedAppModeProvider) ?? AppMode.server;

  void set(AppMode mode) {
    state = mode;
    ref.read(saveAppModeProvider)(mode);
  }
}

final appModeProvider = NotifierProvider<AppModeNotifier, AppMode>(AppModeNotifier.new);

/// Whether this device runs the shop on its own, with no server behind it.
/// What the server owns is then not offered at all: staff, branches, the audit
/// trail, sync — and sign-out, which would wipe the only account there is.
final standaloneProvider =
    Provider<bool>((ref) => ref.watch(appModeProvider) == AppMode.standalone);

/// Phase 0: in-memory implementations from dukan_data. Phase 1 swaps these for
/// Drift (SQLite) repositories without touching call sites.
final stockRepoProvider =
    Provider<StockMovementRepository>((ref) => InMemoryStockMovementRepository());

final outboxProvider = Provider<SyncOutbox>((ref) => InMemorySyncOutbox());

/// Ports implemented in later phases — declared here so the wiring is explicit.
final syncClientProvider = Provider<SyncClient>(
    (ref) => throw UnimplementedError('SyncClient is wired in Phase 6'));

/// Barcode scanner. Defaults to a no-op (no scans) so screens can always read
/// it; main injects the real keyboard-wedge scanner (Phase 8).
final scannerProvider = Provider<BarcodeScanner>((ref) => const _NoopScanner());

class _NoopScanner implements BarcodeScanner {
  const _NoopScanner();
  @override
  Stream<ScanEvent> scans() => const Stream.empty();
}
