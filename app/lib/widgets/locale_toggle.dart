import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../composition.dart';
import '../l10n/app_localizations.dart';

/// The language switch in app bars: one compact button showing the current
/// language, with EN / دری / پښتو to choose from, so a phone's bar keeps room
/// for its title. Drives [localeProvider].
class LocaleToggle extends ConsumerWidget {
  const LocaleToggle({super.key});

  static const _locales = [
    (Locale('en'), 'EN'),
    (Locale('fa', 'AF'), 'دری'),
    (Locale('ps'), 'پښتو'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(localeProvider);
    final label = _locales.firstWhere((e) => e.$1 == active, orElse: () => _locales[1]).$2;
    // A phone's bar is short of room: the icon alone, the menu names the rest.
    final compact = MediaQuery.sizeOf(context).width < 600;
    return PopupMenuButton<Locale>(
      tooltip: AppLocalizations.of(context).language,
      onSelected: (locale) => ref.read(localeProvider.notifier).set(locale),
      itemBuilder: (_) => [
        for (final (locale, name) in _locales)
          CheckedPopupMenuItem(value: locale, checked: locale == active, child: Text(name)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.translate, size: 20),
          if (!compact) ...[const SizedBox(width: 4), Text(label)],
        ]),
      ),
    );
  }
}
