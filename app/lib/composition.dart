import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:dukan_sync/dukan_sync.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root — the one place a concrete class meets an interface.
/// Dependencies point inward: the app wires implementations (dukan_data) to the
/// ports declared in dukan_core, and to sync/hardware ports implemented later.

/// Active UI locale. Defaults to Dari (fa-AF), switchable at runtime.
final class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('fa', 'AF');
  void set(Locale locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

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
