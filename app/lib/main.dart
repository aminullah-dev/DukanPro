import 'package:dukan_core/dukan_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'composition.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(const ProviderScope(child: DukanProApp()));
}

class DukanProApp extends ConsumerWidget {
  const DukanProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F6B5C),
      ),
      home: const _HomeScreen(),
    );
  }
}

/// Phase 0 smoke/home screen: proves the app boots, localizes into all three
/// locales, mirrors to RTL for Dari/Pashto, and renders Perso-Arabic (incl.
/// Pashto) glyphs. The real POS screen arrives in Phase 3 (see the mockup).
class _HomeScreen extends ConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final dir = Directionality.of(context);
    // Exercise a core primitive so the money path is live from day one.
    final samplePrice = Money(52000, 'AFN'); // 520.00 AFN in minor units

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          _LocaleButton(const Locale('en'), 'EN'),
          _LocaleButton(const Locale('fa', 'AF'), 'دری'),
          _LocaleButton(const Locale('ps'), 'پښتو'),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.tagline, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: Text(l.posTitle),
                    subtitle: Text(l.itemsInCart(3)),
                    trailing: Text(
                      '${(samplePrice.amountMinor / 100).toStringAsFixed(2)} AFN',
                      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Pashto glyph coverage check — must render, not show boxes.
                const Card(
                  color: Color(0xFFE3F1ED),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('ټ ډ ړ ږ ښ ګ ڼ — پلور بشپړ شو',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'dir: ${dir == TextDirection.rtl ? 'RTL' : 'LTR'} • id: ${newId().substring(0, 8)}…',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocaleButton extends ConsumerWidget {
  const _LocaleButton(this.locale, this.label);
  final Locale locale;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(localeProvider) == locale;
    return TextButton(
      onPressed: () => ref.read(localeProvider.notifier).set(locale),
      style: TextButton.styleFrom(
        foregroundColor: active ? Colors.white : Colors.white70,
        backgroundColor: active ? Colors.white24 : null,
      ),
      child: Text(label),
    );
  }
}
