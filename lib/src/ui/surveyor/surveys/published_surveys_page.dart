import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';
import '../../shared/loading_error.dart';
import 'fill_survey_page.dart';

class PublishedSurveysPage extends ConsumerWidget {
  const PublishedSurveysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(surveyRepositoryProvider).watchPublishedSurveys();
    return StreamBuilder<List<Survey>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) return ErrorScaffold(message: 'خطأ: ${snap.error}');
        if (!snap.hasData) return const LoadingScaffold();
        final surveys = snap.data!;
        if (surveys.isEmpty) {
          return const Center(child: Text('لا يوجد استبيانات منشورة'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: surveys.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final s = surveys[i];
            return Card(
              child: ListTile(
                title: Text(s.title.isEmpty ? s.id : s.title),
                subtitle: Text(s.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FillSurveyPage(surveyId: s.id)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
