import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';
import '../../shared/loading_error.dart';

class AdminUsersPage extends ConsumerWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersStream = ref.watch(userRepositoryProvider).watchAllUsers();
    return StreamBuilder(
      stream: usersStream,
      builder: (context, snap) {
        if (snap.hasError) return ErrorScaffold(message: 'خطأ: ${snap.error}');
        if (!snap.hasData) return const LoadingScaffold();
        final users = snap.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final u = users[i];
            return Card(
              child: ListTile(
                title: Text(u.name.isEmpty ? u.uid : u.name),
                subtitle: Text('role: ${roleToString(u.role)} • active: ${u.isActive}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    DropdownButton<UserRole>(
                      value: u.role,
                      onChanged: (v) async {
                        if (v == null) return;
                        await ref.read(userRepositoryProvider).setRole(uid: u.uid, role: v);
                      },
                      items: const [
                        DropdownMenuItem(value: UserRole.surveyor, child: Text('surveyor')),
                        DropdownMenuItem(value: UserRole.reviewer, child: Text('reviewer')),
                        DropdownMenuItem(value: UserRole.admin, child: Text('admin')),
                      ],
                    ),
                    Switch(
                      value: u.isActive,
                      onChanged: (v) => ref.read(userRepositoryProvider).setActive(uid: u.uid, isActive: v),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
