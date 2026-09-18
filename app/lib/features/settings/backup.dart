import 'dart:io';

import 'package:dukan_core/dukan_core.dart' show Permission, branchWallClock;
import 'package:dukan_data/dukan_data.dart' show ShopBackup;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../composition.dart';
import '../../infrastructure/file_share.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/dates.dart';
import '../../widgets/password_dialog.dart';
import '../../widgets/share_origin.dart';
import '../auth/auth_controller.dart';
import '../auth/providers.dart';
import '../auth/session.dart';
import 'settings_providers.dart';

/// When this device last sent a backup of the shop somewhere, as ISO-8601 UTC.
const backupLastAtKey = 'backup.last_at';

/// How old a backup may grow before the dashboard asks for a new one.
const backupReminderAfter = Duration(days: 7);

/// Backup files end in this, so a person can tell them from anything else.
const backupExtension = '.dukanpro';

class LastBackupController extends AsyncNotifier<DateTime?> {
  @override
  Future<DateTime?> build() async =>
      DateTime.tryParse(await ref.read(settingsStoreProvider).get(backupLastAtKey) ?? '');

  Future<void> record(DateTime at) async {
    await ref.read(settingsStoreProvider).set(backupLastAtKey, at.toUtc().toIso8601String());
    state = AsyncData(at.toUtc());
  }
}

final lastBackupProvider = AsyncNotifierProvider<LastBackupController, DateTime?>(LastBackupController.new);

/// Backups are for a shop with no server, whose books live on this device
/// alone; a shop with a server keeps them there. Its owner makes them.
final canBackUpProvider = Provider<bool>(
  (ref) => ref.watch(standaloneProvider) && (ref.watch(sessionActorProvider)?.can(Permission.settingsManage) ?? false),
);

/// Asks for the password again, writes the whole shop to a file encrypted with
/// it, and hands the file to the share sheet. Says how it went. The backup
/// counts as made once the file was sent somewhere. [working] hears when the
/// work starts, once the password is right, and when it ends.
Future<void> backUpShop(
  BuildContext context,
  WidgetRef ref, {
  Rect? origin,
  void Function(bool working)? working,
}) async {
  final l = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  void say(String message) => messenger.showSnackBar(SnackBar(content: Text(message)));

  final password = await showDialog<String>(
    context: context,
    builder: (_) => PasswordDialog(title: l.backupPasswordTitle, action: l.backupAction),
  );
  if (password == null || password.isEmpty) return;
  if (!await ref.read(authControllerProvider.notifier).checkPassword(password)) {
    say(l.wrongSecret);
    return;
  }
  working?.call(true);
  try {
    final dir = await ref.read(workDirectoryProvider)();
    // A backup left here from before was sent on already; the newest replaces it.
    for (final old in dir.listSync().whereType<File>()) {
      if (old.path.endsWith(backupExtension)) old.deleteSync();
    }
    final now = ref.read(clockProvider)();
    final day = branchWallClock(ref.read(branchZoneProvider), now);
    String two(int n) => n.toString().padLeft(2, '0');
    final path = '${dir.path}/dukanpro-backup-${day.year}-${two(day.month)}-${two(day.day)}$backupExtension';
    await ShopBackup(ref.read(databaseProvider)).export(path, password);
    if (!await ref.read(shareFileProvider)(path, mimeType: 'application/octet-stream', origin: origin)) return;
    await ref.read(lastBackupProvider.notifier).record(now);
    say(l.backupReady);
  } on Object {
    say(l.backupFailed);
  } finally {
    working?.call(false);
  }
}

/// In settings: make a backup now, and when the last one was made.
class BackupTile extends ConsumerStatefulWidget {
  const BackupTile({super.key});
  @override
  ConsumerState<BackupTile> createState() => _BackupTileState();
}

class _BackupTileState extends ConsumerState<BackupTile> {
  bool _busy = false;

  void _working(bool busy) {
    if (mounted) setState(() => _busy = busy);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(canBackUpProvider)) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final last = ref.watch(lastBackupProvider).asData?.value;
    final zone = ref.watch(branchZoneProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Builder(
          builder: (tileContext) => ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: Text(l.backupShop),
            subtitle: Text(
              '${last == null ? l.backupNever : l.backupLast(formatDateTime(l, last, zone))}\n${l.backupHelp}',
            ),
            isThreeLine: true,
            trailing: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share),
            onTap: _busy ? null : () => backUpShop(context, ref, origin: shareOriginOf(tileContext), working: _working),
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }
}

/// On the dashboard, while a backup is overdue: a lost or broken device would
/// take the shop's books with it.
class BackupReminder extends ConsumerStatefulWidget {
  const BackupReminder({super.key});
  @override
  ConsumerState<BackupReminder> createState() => _BackupReminderState();
}

class _BackupReminderState extends ConsumerState<BackupReminder> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(canBackUpProvider)) return const SizedBox.shrink();
    final async = ref.watch(lastBackupProvider);
    if (!async.hasValue) return const SizedBox.shrink();
    final last = async.value;
    final age = last == null ? null : ref.watch(clockProvider)().toUtc().difference(last);
    if (age != null && age < backupReminderAfter) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  age == null ? l.backupReminderNever : l.backupReminderOld(age.inDays),
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
              const SizedBox(width: 12),
              Builder(
                builder: (buttonContext) => FilledButton(
                  onPressed: _busy
                      ? null
                      : () => backUpShop(
                            context,
                            ref,
                            origin: shareOriginOf(buttonContext),
                            working: (busy) {
                              if (mounted) setState(() => _busy = busy);
                            },
                          ),
                  child: Text(l.backupNow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
