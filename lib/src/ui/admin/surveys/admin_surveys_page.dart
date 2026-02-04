import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';
import '../../shared/loading_error.dart';
import 'survey_editor_page.dart';
import '../../../utils/formatters.dart';

class AdminSurveysPage extends ConsumerWidget {
  const AdminSurveysPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysStream = ref.watch(surveyRepositoryProvider).watchAllSurveys();

    return StreamBuilder<List<Survey>>(
      stream: surveysStream,
      builder: (context, snap) {
        if (snap.hasError) return ErrorScaffold(message: 'خطأ: ${snap.error}');
        if (!snap.hasData) return const LoadingScaffold();
        final surveys = snap.data!;
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('الاستبيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      final auth = ref.read(firebaseAuthProvider);
                      final id = await ref.read(surveyRepositoryProvider).createSurvey(
                            title: 'استبيان جديد',
                            description: '',
                            createdBy: auth.currentUser!.uid,
                          );
                      // open editor
                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SurveyEditorPage(surveyId: id)));
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إنشاء'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: surveys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final s = surveys[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          s.title.isEmpty ? '(بدون عنوان)' : s.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (s.description.trim().isNotEmpty)
                              Text(
                                s.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                Chip(label: Text('الحالة: ${surveyStatusLabelAr(s.status)}')),
                                Chip(label: Text('الإصدار: v${s.version}')),
                                Chip(label: Text('آخر تحديث: ${Formatters.ts(s.updatedAt)}')),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SurveyEditorPage(surveyId: s.id)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
