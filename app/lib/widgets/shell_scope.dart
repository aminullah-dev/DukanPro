import 'package:flutter/material.dart';

/// Tells a pane of the app shell how it is shown. On a phone the shell's
/// destinations live in a drawer and each pane's app bar opens it with
/// [menuButton]; beside the wide layout's rail, and on pages pushed over the
/// shell (which are not under this scope), there is no menu button.
class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.wide, required this.openMenu, required super.child});
  final bool wide;
  final VoidCallback openMenu;

  static ShellScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ShellScope>();

  /// A pane's app-bar leading button: the menu on a phone, else null (the
  /// default, a back button on a pushed page).
  static Widget? menuButton(BuildContext context) {
    final scope = maybeOf(context);
    if (scope == null || scope.wide) return null;
    return IconButton(
      icon: const Icon(Icons.menu),
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: scope.openMenu,
    );
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => oldWidget.wide != wide;
}
