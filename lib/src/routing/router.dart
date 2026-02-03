import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../ui/auth/login_page.dart';
import '../ui/auth/register_page.dart';
import '../ui/home/role_home.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authRepositoryProvider).authStateChanges();

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authStream),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RoleHomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text('Page not found: ${state.uri}'),
        ),
      );
    },
    redirect: (context, state) {
      final user = ref.read(firebaseAuthProvider).currentUser;
      final location = state.uri.toString();

      final isAuthRoute = location.startsWith('/login') || location.startsWith('/register');

      // Not signed in -> only allow auth routes.
      if (user == null) {
        return isAuthRoute ? null : '/login';
      }

      // Signed in -> keep them away from login/register.
      if (isAuthRoute) return '/';

      return null;
    },
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
