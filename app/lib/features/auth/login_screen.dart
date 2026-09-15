import 'package:dukan_core/dukan_core.dart' show loginLockMinutes;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/locale_toggle.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

/// What this screen is doing: signing in to a shop that exists, or setting a
/// new one up — with a server behind it, or on this device alone.
enum _Mode { signIn, serverSetup, standaloneSetup }

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
  final _setupCode = TextEditingController();
  _Mode _mode = _Mode.signIn;
  bool _busy = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _displayName.dispose();
    _shopName.dispose();
    _setupCode.dispose();
    super.dispose();
  }

  // Setting a shop up needs a name for it (it heads every receipt) and a
  // username to own it. Signing in lets the server answer instead.
  String? _shopError;
  String? _usernameError;

  bool get _settingUp => _mode != _Mode.signIn;

  Future<void> _submit() async {
    if (_settingUp && !_setupFieldsFilled()) return;
    setState(() => _busy = true);
    final controller = ref.read(authControllerProvider.notifier);
    final username = _username.text.trim();
    final typedName = _displayName.text.trim();
    final displayName = typedName.isEmpty ? username : typedName;
    try {
      switch (_mode) {
        case _Mode.signIn:
          await controller.loginOnline(username: username, password: _password.text);
        case _Mode.serverSetup:
          await controller.bootstrap(
            username: username,
            password: _password.text,
            displayName: displayName,
            shopName: _shopName.text.trim(),
            setupCode: _setupCode.text.trim(),
          );
        case _Mode.standaloneSetup:
          await controller.setupStandalone(
            username: username,
            password: _password.text,
            displayName: displayName,
            shopName: _shopName.text.trim(),
          );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Whether the shop's name and a username are there, marking what is missing.
  bool _setupFieldsFilled() {
    final required = AppLocalizations.of(context).errRequired;
    final shop = _shopName.text.trim().isEmpty ? required : null;
    final user = _username.text.trim().isEmpty ? required : null;
    setState(() {
      _shopError = shop;
      _usernameError = user;
    });
    return shop == null && user == null;
  }

  void _switchTo(_Mode mode) {
    ref.read(authControllerProvider.notifier).clearError();
    setState(() {
      _mode = mode;
      _shopError = null;
      _usernameError = null;
    });
  }

  String _label(AppLocalizations l, _Mode mode) => switch (mode) {
        _Mode.signIn => l.signIn,
        _Mode.serverSetup => l.firstRunSetup,
        _Mode.standaloneSetup => l.standaloneSetup,
      };

  /// Map a server/transport error code to a message that fits the situation.
  String _errorText(AppLocalizations l, String code) => switch (code) {
        'NETWORK' => l.errNetwork,
        'INVALID_CREDENTIALS' => l.loginFailed,
        'LOGIN_LOCKED' => l.errLoginLocked(loginLockMinutes),
        'BOOTSTRAP_ALREADY_DONE' => l.errBootstrapDone,
        'SETUP_TOKEN_INVALID' => l.errSetupCode,
        'WEAK_PASSWORD' => l.errWeakPassword,
        'OFFLINE_EXPIRED' => l.errOfflineExpired,
        'STORAGE_UNAVAILABLE' => l.errStorage,
        'USER_DISABLED' => l.errAccountDisabled, // signing in again cannot help
        'SESSION_REVOKED' || 'REFRESH_INVALID' || 'TOKEN_INVALID' => l.errSessionEnded,
        _ => _settingUp ? l.setupFailed : l.loginFailed,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(authControllerProvider);
    final error = state is AuthLoggedOut ? state.error : null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle), actions: const [LocaleToggle(), SizedBox(width: 8)]),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Text(l.tagline, style: theme.textTheme.titleMedium),
              if (_mode == _Mode.standaloneSetup) ...[
                const SizedBox(height: 8),
                Text(l.standaloneSetupHelp, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _username,
                autocorrect: false,
                onChanged: (_) {
                  if (_usernameError != null) setState(() => _usernameError = null);
                },
                decoration: InputDecoration(
                  labelText: l.username,
                  errorText: _usernameError,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(labelText: l.password, border: const OutlineInputBorder()),
              ),
              if (_mode == _Mode.standaloneSetup) ...[
                const SizedBox(height: 8),
                // Nothing of this shop is kept anywhere else: say so while the
                // password is still being chosen, not after it is forgotten.
                Text(l.standalonePasswordWarning, style: theme.textTheme.bodySmall),
              ],
              if (_settingUp) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _displayName,
                  decoration: InputDecoration(labelText: l.displayName, border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _shopName,
                  onChanged: (_) {
                    if (_shopError != null) setState(() => _shopError = null);
                  },
                  decoration: InputDecoration(
                    labelText: l.shopName, errorText: _shopError, border: const OutlineInputBorder(),
                  ),
                ),
              ],
              if (_mode == _Mode.serverSetup) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _setupCode,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: l.setupCode,
                    helperText: l.setupCodeHelp,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText(l, error),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_label(l, _mode)),
              ),
              // The other two ways in are always in reach, so a shop with no
              // server is offered rather than hidden behind a setting.
              for (final other in _Mode.values)
                if (other != _mode)
                  TextButton(
                    onPressed: _busy ? null : () => _switchTo(other),
                    child: Text(_label(l, other)),
                  ),
              if (state is AuthLoggedOut && state.canReturn)
                TextButton(
                  onPressed: _busy ? null : () => ref.read(authControllerProvider.notifier).restore(),
                  child: Text(l.backToUnlock),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
