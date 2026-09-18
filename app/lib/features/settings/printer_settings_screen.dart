import 'dart:async';

import 'package:dukan_core/dukan_core.dart' show Permission;
import 'package:dukan_hardware/dukan_hardware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/plugin_printers.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bidi.dart';
import '../../widgets/error_text.dart';
import '../../widgets/password_dialog.dart';
import '../pos/receipt_raster.dart';
import '../auth/session.dart';
import '../../widgets/shell_scope.dart';
import '../auth/auth_controller.dart';
import '../auth/providers.dart';
import 'backup.dart';
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
  PrinterTransport _transport = PrinterTransport.tcp;
  String _deviceId = '';
  String _deviceName = '';
  int _paperMm = 80;
  bool _loaded = false;

  /// What the latest search for Bluetooth, BLE or USB printers found so far.
  List<FoundPrinter> _found = const [];
  StreamSubscription<List<FoundPrinter>>? _search;
  bool _searching = false;
  String? _searchProblem;

  @override
  void dispose() {
    _search?.cancel();
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  void _hydrate(PrinterConfig c) {
    if (_loaded) return;
    _loaded = true;
    _enabled = c.enabled;
    // Settings only ever offer this device's transports; anything else reads as a network printer.
    _transport = ref.read(printerTransportsProvider).contains(c.transport) ? c.transport : PrinterTransport.tcp;
    _host.text = c.host;
    _port.text = c.port.toString();
    _deviceId = c.deviceId;
    _deviceName = c.deviceName;
    _paperMm = c.paperMm;
  }

  PrinterConfig get _current => PrinterConfig(
        enabled: _enabled,
        transport: _transport,
        host: _host.text.trim(),
        port: int.tryParse(_port.text.trim()) ?? 9100,
        deviceId: _deviceId,
        deviceName: _deviceName,
        paperMm: _paperMm,
      );

  void _say(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save(AppLocalizations l) async {
    await ref.read(printerSettingsControllerProvider.notifier).save(_current);
    if (mounted) _say(l.savedOk);
  }

  void _chooseTransport(PrinterTransport transport) {
    if (transport == _transport) return;
    _search?.cancel();
    setState(() {
      _transport = transport;
      // A printer found one way cannot be reached another way.
      _deviceId = '';
      _deviceName = '';
      _found = const [];
      _searching = false;
      _searchProblem = null;
    });
  }

  void _find(AppLocalizations l) {
    _search?.cancel();
    setState(() {
      _found = const [];
      _searching = true;
      _searchProblem = null;
    });
    _search = ref.read(printerFinderProvider).find(_transport).listen(
      (found) {
        if (mounted) setState(() => _found = found);
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _searching = false;
          _searchProblem = e is PrinterAccessDenied ? l.printerPermissionDenied : l.noPrintersFound;
        });
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _searching = false;
          if (_found.isEmpty) _searchProblem = l.noPrintersFound;
        });
      },
      cancelOnError: true,
    );
  }

  Future<void> _testPrint(AppLocalizations l) async {
    final cfg = _current;
    if (!cfg.isReady) {
      _say(l.printerNotConfigured);
      return;
    }
    final printer = ref.read(printerForProvider)(cfg);
    try {
      // A sample in the reader's language: the page shows that Dari or Pashto prints.
      final image = await rasterReceipt(
        l: l,
        data: ReceiptData(
          shopName: ref.read(shopNameProvider), number: l.testPrint, stamp: '',
          lines: [ReceiptLineData(name: l.testPrint, qtyLabel: '×1', lineTotalMinor: 0)],
          subtotalMinor: 0, totalMinor: 0, paidMinor: 0, changeMinor: 0, currency: ref.read(shopCurrencyProvider),
        ),
        occurredAt: DateTime.now(), zone: ref.read(branchZoneProvider), paperMm: cfg.paperMm,
      );
      await printer.printRaw(const EscPosEncoder().encodeRaster(image)).timeout(printJobTimeout(printer.transport));
      if (mounted) _say(l.printSucceeded);
    } on PrinterAccessDenied {
      if (mounted) _say(l.printerPermissionDenied);
    } on Object {
      if (mounted) _say(l.printFailed);
    }
  }

  String _transportLabel(AppLocalizations l, PrinterTransport t) => switch (t) {
        PrinterTransport.tcp => l.printerTransportTcp,
        PrinterTransport.bluetooth => l.printerTransportBluetooth,
        PrinterTransport.ble => l.printerTransportBle,
        PrinterTransport.usb => l.printerTransportUsb,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(printerSettingsControllerProvider);
    return Scaffold(
      appBar: AppBar(leading: ShellScope.menuButton(context), title: Text(l.settings)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorMessage(e),
        data: (config) {
          _hydrate(config);
          final theme = Theme.of(context);
          final transports = ref.watch(printerTransportsProvider);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const BackupTile(),
              const _BiometricTile(),
              const IdleLockTile(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l.printerSettings, style: theme.textTheme.titleSmall),
              ),
              SwitchListTile(
                title: Text(l.enablePrinting),
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
              ),
              const SizedBox(height: 8),
              if (transports.length > 1) ...[
                Text(l.printerConnection, style: theme.textTheme.bodyMedium),
                DropdownButton<PrinterTransport>(
                  isExpanded: true,
                  value: _transport,
                  items: [
                    for (final t in transports) DropdownMenuItem(value: t, child: Text(_transportLabel(l, t))),
                  ],
                  onChanged: _enabled
                      ? (t) {
                          if (t != null) _chooseTransport(t);
                        }
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              if (_transport == PrinterTransport.tcp) ...[
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
              ] else ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.print_outlined),
                  title: Text(_deviceId.isEmpty ? l.noPrinterChosen : _deviceName),
                  // An address or a vendor:product pair reads left to right in any language.
                  subtitle: _deviceId.isEmpty ? null : Text(ltr(_deviceId)),
                ),
                OutlinedButton.icon(
                  onPressed: _enabled && !_searching ? () => _find(l) : null,
                  icon: _searching
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.search),
                  label: Text(_searching ? l.findingPrinters : l.findPrinters),
                ),
                if (_searchProblem != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_searchProblem!, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                for (final p in _found)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: _enabled,
                    leading: Icon(p.id == _deviceId ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                    title: Text(p.name),
                    subtitle: Text(ltr(p.id)),
                    onTap: () => setState(() {
                      _deviceId = p.id;
                      _deviceName = p.name;
                    }),
                  ),
              ],
              const SizedBox(height: 12),
              Text(l.paperWidth, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              SegmentedButton<int>(
                segments: [
                  for (final mm in const [58, 80]) ButtonSegment(value: mm, label: Text(l.paperMillimetres(mm))),
                ],
                selected: {_paperMm},
                onSelectionChanged: _enabled ? (s) => setState(() => _paperMm = s.first) : null,
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

/// Opt in to fingerprint unlock for the signed-in user on this device,
/// confirmed with the app password. Hidden when the device has no biometrics.
class _BiometricTile extends ConsumerStatefulWidget {
  const _BiometricTile();
  @override
  ConsumerState<_BiometricTile> createState() => _BiometricTileState();
}

class _BiometricTileState extends ConsumerState<_BiometricTile> {
  bool _available = false;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available = await ref.read(biometricProvider).isAvailable();
    final enabled = await ref.read(authControllerProvider.notifier).biometricEnabled();
    if (mounted) {
      setState(() {
        _available = available;
        _enabled = enabled;
      });
    }
  }

  Future<void> _toggle(bool on, AppLocalizations l) async {
    final controller = ref.read(authControllerProvider.notifier);
    if (on) {
      final password = await showDialog<String>(context: context, builder: (_) => const PasswordDialog());
      if (password == null) return;
      if (!await controller.enableBiometric(password)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.wrongSecret)));
        return;
      }
    } else {
      await controller.disableBiometric();
    }
    if (mounted) setState(() => _enabled = on);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (!_available) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.fingerprint),
          title: Text(l.biometricUnlockSetting),
          value: _enabled,
          onChanged: (v) => _toggle(v, l),
        ),
        const Divider(height: 24),
      ],
    );
  }
}

/// How soon this device locks when nobody touches it. Everyone sees the value;
/// only an owner or a manager (settings.manage) can change it.
class IdleLockTile extends ConsumerWidget {
  const IdleLockTile({super.key});

  Future<void> _choose(BuildContext context, WidgetRef ref, int minutes) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(idleLockProvider.notifier).save(minutes);
      messenger.showSnackBar(SnackBar(content: Text(l.savedOk)));
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(appErrorText(l, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final minutes = ref.watch(idleLockProvider).asData?.value;
    if (minutes == null) return const SizedBox.shrink();
    final canChange = ref.watch(sessionActorProvider)?.can(Permission.settingsManage) ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.lock_clock),
          title: Text(l.idleLockSetting),
          subtitle: canChange ? null : Text(l.idleLockManagersOnly),
          trailing: DropdownButton<int>(
            value: minutes,
            items: [
              for (final m in kIdleLockChoices) DropdownMenuItem(value: m, child: Text(l.idleLockMinutes(m))),
            ],
            onChanged: canChange
                ? (m) {
                    if (m != null && m != minutes) _choose(context, ref, m);
                  }
                : null,
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }
}
