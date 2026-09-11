import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../composition.dart';

/// EN / دری / پښتو switch shown in app bars. Drives [localeProvider].
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (locale, label) in _locales)
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).set(locale),
            style: TextButton.styleFrom(
              minimumSize: const Size(40, 40),
              foregroundColor: active == locale ? null : Theme.of(context).hintColor,
            ),
            child: Text(label),
          ),
      ],
    );
  }
}
