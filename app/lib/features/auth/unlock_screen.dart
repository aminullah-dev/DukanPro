import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/locale_toggle.dart';
import 'auth_controller.dart';
import 'auth_state.dart';
import 'providers.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});
  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _secret = TextEditingController();
  bool _busy = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  /// The fingerprint button shows only when the device supports it and the
  /// cached user opted in.
  Future<void> _checkBiometric() async {
    final available = await ref.read(biometricProvider).isAvailable() &&
        await ref.read(authControllerProvider.notifier).biometricEnabled();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  @override
  void dispose() {
    _secret.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final controller = ref.read(authControllerProvider.notifier);
    final password = _secret.text;
    setState(() => _busy = true);
    try {
      await controller.unlockWithPassword(password);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    // Once unlocked, confirm the user with the server if it is reachable; a
    // session that simply ended renews with this password.
    unawaited(controller.revalidate(password: password));
  }

  Future<void> _unlockWithBiometric() async {
    final controller = ref.read(authControllerProvider.notifier);
    if (await controller.unlockWithBiometric()) unawaited(controller.revalidate());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final username = state is AuthLocked ? state.profile.username : '';
    final error = state is AuthLocked ? state.error : null;

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle), actions: const [LocaleToggle(), SizedBox(width: 8)]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Icon(Icons.lock_outline, size: 40, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(l.signedInAs(username),
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              TextField(
                controller: _secret,
                obscureText: true,
                onSubmitted: (_) => _unlock(),
                decoration: InputDecoration(labelText: l.password, border: const OutlineInputBorder()),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  // A wrong password, or a session the server ended: then the
                  // password is what signs in again.
                  error == 'WRONG_SECRET' ? l.wrongSecret : l.errSessionEndedUnlock,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _unlock,
                child: _busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l.unlock),
              ),
              if (_biometricAvailable)
                TextButton.icon(
                  onPressed: _unlockWithBiometric,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l.useBiometric),
                ),
              // Signing out here would wipe the saved sign-in without any password;
              // from the lock screen one can only switch to another account.
              TextButton(
                onPressed: () => ref.read(authControllerProvider.notifier).useAnotherAccount(),
                child: Text(l.useAnotherAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
