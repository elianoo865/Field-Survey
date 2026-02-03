import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';
import '../../shared/loading_error.dart';
import 'survey_editor_page.dart';

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
                        title: Text(s.title.isEmpty ? '(بدون عنوان)' : s.title),
                        subtitle: Text('الحالة: ${surveyStatusToString(s.status)}  •  v${s.version}'),
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
