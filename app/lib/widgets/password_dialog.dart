import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Asks for a password again before something weighty. Pops with what was
/// typed, or with null when cancelled.
class PasswordDialog extends StatefulWidget {
  const PasswordDialog({super.key, this.title, this.action});

  /// Defaults to asking the person to confirm their password.
  final String? title;

  /// What the confirming button does; defaults to saving.
  final String? action;

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true, // the keyboard can take half a phone's height
      title: Text(widget.title ?? l.confirmPasswordTitle),
      content: TextField(
        controller: _field,
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(labelText: l.password),
        onSubmitted: (text) => Navigator.pop(context, text),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(onPressed: () => Navigator.pop(context, _field.text), child: Text(widget.action ?? l.save)),
      ],
    );
  }
}
