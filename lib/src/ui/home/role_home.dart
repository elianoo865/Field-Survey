import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../shared/loading_error.dart';
import '../admin/admin_home.dart';
import '../surveyor/surveyor_home.dart';

class RoleHomePage extends ConsumerStatefulWidget {
  const RoleHomePage({super.key});

  @override
  ConsumerState<RoleHomePage> createState() => _RoleHomePageState();
}

class _RoleHomePageState extends ConsumerState<RoleHomePage> {
  bool _didRetry = false;

  bool _isPermissionDenied(Object e) {
    // FirebaseException code is 'permission-denied' for Firestore rules failures
    return e.toString().contains('permission-denied') ||
        e.toString().contains('Missing or insufficient permissions');
  }

  void _scheduleRetry() {
    if (_didRetry) return;
    _didRetry = true;
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      ref.invalidate(myProfileProvider);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      loading: () => const LoadingScaffold(),
      error: (e, _) {
        if (_isPermissionDenied(e)) {
          // Sometimes right after login the auth token isn't fully applied to Firestore yet.
          // We auto-retry once instead of forcing the user to refresh the page.
          _scheduleRetry();
          return const LoadingScaffold(message: 'جارٍ تهيئة الحساب... لحظة');
        }
        return ErrorScaffold(message: 'خطأ بجلب بيانات المستخدم: $e');
      },
      data: (profile) {
        if (profile == null) {
          return const LoadingScaffold(message: 'جارٍ تهيئة الحساب...');
        }
        if (!profile.isActive) {
          return const ErrorScaffold(message: 'هذا الحساب غير مفعل. راجع الأدمن.');
        }
        switch (profile.role) {
          case UserRole.admin:
            return const AdminHomePage();
          case UserRole.reviewer:
          case UserRole.surveyor:
            return const SurveyorHomePage();
        }
      },
    );
  }
}
