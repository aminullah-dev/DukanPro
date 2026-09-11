import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/locale_toggle.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  final _shopName = TextEditingController();
  bool _setup = false;
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _displayName.dispose();
    _shopName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final controller = ref.read(authControllerProvider.notifier);
    final username = _username.text.trim();
    if (_setup) {
      await controller.bootstrap(
        username: username,
        password: _password.text,
        displayName: _displayName.text.trim().isEmpty ? username : _displayName.text.trim(),
        shopName: _shopName.text.trim().isEmpty ? 'My Shop' : _shopName.text.trim(),
      );
    } else {
      await controller.loginOnline(username: username, password: _password.text);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final error = state is AuthLoggedOut ? state.error : null;

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle), actions: const [LocaleToggle(), SizedBox(width: 8)]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text(l.tagline, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              TextField(
                controller: _username,
                autocorrect: false,
                decoration: InputDecoration(labelText: l.username, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: l.password, border: const OutlineInputBorder()),
              ),
              if (_setup) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _displayName,
                  decoration: InputDecoration(labelText: l.displayName, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _shopName,
                  decoration: InputDecoration(labelText: l.shopName, border: const OutlineInputBorder()),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(l.loginFailed, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_setup ? l.firstRunSetup : l.signIn),
              ),
              TextButton(
                onPressed: _busy ? null : () => setState(() => _setup = !_setup),
                child: Text(_setup ? l.signIn : l.firstRunSetup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
