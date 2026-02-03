import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/providers.dart';
import '../../shared/loading_error.dart';

class MyResponsesPage extends ConsumerWidget {
  const MyResponsesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);
    final uid = auth.currentUser?.uid;
    if (uid == null) return const ErrorScaffold(message: 'غير مسجل دخول');

    final stream = ref.watch(responseRepositoryProvider).watchMyResponses(uid);
    return StreamBuilder(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) return ErrorScaffold(message: 'خطأ: ${snap.error}');
        if (!snap.hasData) return const LoadingScaffold();
        final docs = snap.data!;
        if (docs.isEmpty) return const Center(child: Text('لا يوجد إدخالات بعد'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final surveyId = (d['surveyId'] ?? '') as String;
            final loc = d['location'] as Map?;
            return Card(
              child: ListTile(
                title: Text('Survey: $surveyId'),
                subtitle: Text('GPS: ${loc?['lat']}, ${loc?['lng']}'),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(child: Text(d.toString())),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
