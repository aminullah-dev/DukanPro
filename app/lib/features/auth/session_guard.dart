import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Locks the app when it goes to the background or sits idle for [idleLock], so
/// an unattended till never stays open as its last user. Locking keeps the
/// saved sign-in. The idle time is a device setting (see `idleLockProvider`).
///
/// Every pointer or key event anywhere in the app counts as activity, including
/// screens and dialogs pushed above the shell: they are not inside this widget,
/// so it listens to the global pointer route rather than its own subtree.
class SessionGuard extends StatefulWidget {
  const SessionGuard({
    required this.onLock,
    required this.child,
    this.idleLock = const Duration(minutes: 10),
    super.key,
  });

  final VoidCallback onLock;
  final Duration idleLock;
  final Widget child;

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  late final AppLifecycleListener _lifecycle;
  Timer? _idle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _lock, onPause: _lock);
    HardwareKeyboard.instance.addHandler(_onKey);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    _touch();
  }

  @override
  void didUpdateWidget(SessionGuard old) {
    super.didUpdateWidget(old);
    // A new idle time, chosen in settings, counts from the moment it is chosen.
    if (old.idleLock != widget.idleLock) _touch();
  }

  @override
  void dispose() {
    _idle?.cancel();
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    HardwareKeyboard.instance.removeHandler(_onKey);
    _lifecycle.dispose();
    super.dispose();
  }

  void _lock() => widget.onLock();

  void _touch() {
    _idle?.cancel();
    _idle = Timer(widget.idleLock, _lock);
  }

  void _onPointer(PointerEvent event) {
    if (event is PointerDownEvent || event is PointerSignalEvent) _touch();
  }

  bool _onKey(KeyEvent event) {
    _touch(); // scanner input is activity too
    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
