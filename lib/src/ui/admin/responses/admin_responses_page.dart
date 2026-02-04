import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';
import '../../shared/loading_error.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/location_map.dart';

class AdminResponsesPage extends ConsumerStatefulWidget {
  const AdminResponsesPage({super.key});

  @override
  ConsumerState<AdminResponsesPage> createState() => _AdminResponsesPageState();
}

class _AdminResponsesPageState extends ConsumerState<AdminResponsesPage> {
  String? _selectedSurveyId;
  bool _exporting = false;

  Future<void> _exportXlsx() async {
    if (_selectedSurveyId == null) return;
    setState(() => _exporting = true);
    try {
      final fn = FirebaseFunctions.instance.httpsCallable('exportSurveyXlsx');
      final res = await fn.call({'surveyId': _selectedSurveyId});
      final url = (res.data as Map)['url'] as String?;
      if (url == null) throw Exception('No url returned');
      if (!mounted) return;
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل التصدير: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surveysStream = ref.watch(surveyRepositoryProvider).watchAllSurveys();
    return StreamBuilder<List<Survey>>(
      stream: surveysStream,
      builder: (context, snap) {
        if (snap.hasError) return ErrorScaffold(message: 'خطأ: ${snap.error}');
        if (!snap.hasData) return const LoadingScaffold();
        final surveys = snap.data!;
        _selectedSurveyId ??= surveys.isNotEmpty ? surveys.first.id : null;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('نتائج الاستبيانات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _selectedSurveyId,
                    items: surveys
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.title.isEmpty ? s.id : s.title)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSurveyId = v),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _exporting ? null : _exportXlsx,
                    icon: const Icon(Icons.download),
                    label: Text(_exporting ? '...' : 'Export XLSX'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedSurveyId == null)
                const Expanded(child: Center(child: Text('لا يوجد استبيانات')))
              else
                Expanded(
                  child: StreamBuilder(
                    stream: ref.watch(responseRepositoryProvider).watchSurveyResponses(_selectedSurveyId!),
                    builder: (context, snapR) {
                      if (snapR.hasError) return ErrorScaffold(message: 'خطأ: ${snapR.error}');
                      if (!snapR.hasData) return const LoadingScaffold();
                      final docs = snapR.data!;
                      if (docs.isEmpty) return const Center(child: Text('لا يوجد نتائج بعد'));
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final d = docs[i].data();
                          final name = (d['enteredByName'] ?? '') as String;
                          final loc = parseLocationMap(d['location'] as Map?);
                          return Card(
                            child: ListTile(
                              title: Text(name.isEmpty ? (d['enteredByUid'] ?? '') : name),
                              subtitle: Text(loc == null ? 'GPS: غير متوفر' : 'GPS: ${loc.formatShort()}'),
                              trailing: loc == null
                                  ? const Icon(Icons.chevron_right)
                                  : LocationActions(location: loc, sheetTitle: name),
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
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
