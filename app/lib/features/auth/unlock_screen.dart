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
    ref.read(biometricProvider).isAvailable().then((v) {
      if (mounted) setState(() => _biometricAvailable = v);
    });
  }

  @override
  void dispose() {
    _secret.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    setState(() => _busy = true);
    await ref.read(authControllerProvider.notifier).unlockWithPassword(_secret.text);
    if (mounted) setState(() => _busy = false);
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
                Text(l.wrongSecret, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
                  onPressed: () => ref.read(authControllerProvider.notifier).unlockWithBiometric(),
                  icon: const Icon(Icons.fingerprint),
                  label: Text(l.useBiometric),
                ),
              TextButton(
                onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                child: Text(l.logout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
