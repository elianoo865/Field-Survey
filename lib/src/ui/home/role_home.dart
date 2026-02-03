import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models.dart';
import '../../state/providers.dart';
import '../shared/loading_error.dart';
import '../admin/admin_home.dart';
import '../surveyor/surveyor_home.dart';

class RoleHomePage extends ConsumerWidget {
  const RoleHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(myProfileProvider);

    return profileAsync.when(
      loading: () => const LoadingScaffold(),
      error: (e, _) => ErrorScaffold(message: 'خطأ بجلب بيانات المستخدم: $e'),
      data: (profile) {
        if (profile == null) {
          return const LoadingScaffold();
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
