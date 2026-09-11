import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/auth_state.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/unlock_screen.dart';

/// App router. Redirects based on [AuthState]; refreshes whenever auth changes.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AuthState>(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _Splash()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/unlock', builder: (_, _) => const UnlockScreen()),
      GoRoute(path: '/home', builder: (_, _) => const AppShell()),
    ],
    redirect: (context, gState) {
      final target = switch (ref.read(authControllerProvider)) {
        AuthUnknown() => '/',
        AuthLoggedOut() => '/login',
        AuthLocked() => '/unlock',
        AuthLoggedIn() => '/home',
      };
      return gState.matchedLocation == target ? null : target;
    },
  );
});

/// Initial route while restoring the cached session. Kicks off restore() once.
class _Splash extends ConsumerStatefulWidget {
  const _Splash();
  @override
  ConsumerState<_Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<_Splash> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authControllerProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
