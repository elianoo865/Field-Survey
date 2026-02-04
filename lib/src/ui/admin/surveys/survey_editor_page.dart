import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';
import '../../shared/loading_error.dart';
import 'question_editor_dialog.dart';
import '../../../utils/formatters.dart';

class SurveyEditorPage extends ConsumerStatefulWidget {
  final String surveyId;
  const SurveyEditorPage({super.key, required this.surveyId});

  @override
  ConsumerState<SurveyEditorPage> createState() => _SurveyEditorPageState();
}

class _SurveyEditorPageState extends ConsumerState<SurveyEditorPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surveyRef = ref.watch(firestoreProvider).collection('surveys').doc(widget.surveyId);
    return StreamBuilder(
      stream: surveyRef.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return ErrorScaffold(message: 'خطأ: ${snap.error}');
        if (!snap.hasData) return const LoadingScaffold();
        final survey = Survey.fromDoc(snap.data! as dynamic);

        if (!_loaded) {
          _loaded = true;
          _title.text = survey.title;
          _desc.text = survey.description;
        }

        final questionsStream = ref.watch(surveyRepositoryProvider).watchQuestions(widget.surveyId);

        return Scaffold(
          appBar: AppBar(
            title: const Text('تحرير الاستبيان'),
            actions: [
              TextButton(
                onPressed: () async {
                  await ref.read(surveyRepositoryProvider).updateSurveyMeta(
                        surveyId: widget.surveyId,
                        title: _title.text.trim(),
                        description: _desc.text.trim(),
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ')));
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          controller: _title,
                          decoration: const InputDecoration(labelText: 'عنوان الاستبيان'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _desc,
                          decoration: const InputDecoration(labelText: 'وصف'),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Chip(label: Text('الحالة: ${surveyStatusLabelAr(survey.status)}')),
                            const SizedBox(width: 8),
                            const Chip(label: Text('GPS إلزامي دائماً')),
                            const SizedBox(width: 8),
                            Chip(label: Text('آخر تحديث: ${Formatters.ts(survey.updatedAt)}')),
                            const Spacer(),
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                final next = survey.status == SurveyStatus.published ? SurveyStatus.draft : SurveyStatus.published;
                                await ref.read(surveyRepositoryProvider).setStatus(surveyId: survey.id, status: next);
                              },
                              icon: Icon(survey.status == SurveyStatus.published ? Icons.unpublished : Icons.publish),
                              label: Text(survey.status == SurveyStatus.published ? 'إلغاء النشر' : 'نشر'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text('الأسئلة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        final existing = await surveyRef.collection('questions').get();
                        final nextOrder = existing.docs.length;
                        if (!context.mounted) return;
                        await showDialog(
                          context: context,
                          builder: (_) => QuestionEditorDialog(
                            surveyId: widget.surveyId,
                            initialOrder: nextOrder,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('سؤال'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<SurveyQuestion>>(
                    stream: questionsStream,
                    builder: (context, snapQ) {
                      if (snapQ.hasError) return ErrorScaffold(message: 'خطأ: ${snapQ.error}');
                      if (!snapQ.hasData) return const LoadingScaffold();
                      final qs = snapQ.data!;
                      if (qs.isEmpty) {
                        return const Center(child: Text('لا يوجد أسئلة بعد'));
                      }
                      return ListView.separated(
                        itemCount: qs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final q = qs[i];
                          return Opacity(
                            opacity: q.isDeleted ? 0.5 : 1,
                            child: Card(
                              child: ListTile(
                                title: Text(q.label.isEmpty ? '(بدون نص)' : q.label),
                                subtitle: Text(
                                  'النوع: ${questionTypeLabelAr(q.type)} • مطلوب: ${Formatters.boolAr(q.required)} • ترتيب: ${q.order}${q.isDeleted ? " • (محذوف)" : ""}',
                                ),
                                trailing: Wrap(
                                  spacing: 6,
                                  children: [
                                    IconButton(
                                      tooltip: 'أعلى',
                                      onPressed: i == 0
                                          ? null
                                          : () async {
                                              await ref.read(surveyRepositoryProvider).swapQuestionOrders(
                                                    surveyId: widget.surveyId,
                                                    aQuestionId: q.id,
                                                    bQuestionId: qs[i - 1].id,
                                                  );
                                            },
                                      icon: const Icon(Icons.arrow_upward),
                                    ),
                                    IconButton(
                                      tooltip: 'أسفل',
                                      onPressed: i == qs.length - 1
                                          ? null
                                          : () async {
                                              await ref.read(surveyRepositoryProvider).swapQuestionOrders(
                                                    surveyId: widget.surveyId,
                                                    aQuestionId: q.id,
                                                    bQuestionId: qs[i + 1].id,
                                                  );
                                            },
                                      icon: const Icon(Icons.arrow_downward),
                                    ),
                                    IconButton(
                                      tooltip: 'تعديل',
                                      onPressed: () async {
                                        if (!context.mounted) return;
                                        await showDialog(
                                          context: context,
                                          builder: (_) => QuestionEditorDialog(
                                            surveyId: widget.surveyId,
                                            questionId: q.id,
                                            initialOrder: q.order,
                                            initialLabel: q.label,
                                            initialType: q.type,
                                            initialRequired: q.required,
                                            initialOptions: q.options,
                                            initialIsDeleted: q.isDeleted,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      tooltip: 'حذف (Soft)',
                                      onPressed: q.isDeleted
                                          ? null
                                          : () async {
                                              await ref.read(surveyRepositoryProvider).softDeleteQuestion(
                                                    surveyId: widget.surveyId,
                                                    questionId: q.id,
                                                  );
                                            },
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
