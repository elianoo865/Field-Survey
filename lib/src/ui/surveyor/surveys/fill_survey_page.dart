import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';
import '../../../utils/gps_service.dart';
import '../../shared/loading_error.dart';
import '../../shared/location_map.dart';

class FillSurveyPage extends ConsumerStatefulWidget {
  final String surveyId;
  const FillSurveyPage({super.key, required this.surveyId});

  @override
  ConsumerState<FillSurveyPage> createState() => _FillSurveyPageState();
}

class _FillSurveyPageState extends ConsumerState<FillSurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final _answers = <String, dynamic>{};
  GeoPointLite? _gps;
  bool _submitting = false;
  String? _gpsError;

  final _uuid = const Uuid();
  final _gpsService = GpsService();

  Future<void> _captureGps() async {
    setState(() {
      _gpsError = null;
    });
    try {
      final pos = await _gpsService.capturePosition();
      setState(() {
        _gps = GeoPointLite(
          lat: pos.latitude,
          lng: pos.longitude,
          accuracy: pos.accuracy,
          capturedAt: DateTime.now(),
        );
      });
    } catch (e) {
      setState(() {
        _gps = null;
        _gpsError = e.toString();
      });
    }
  }

  Future<void> _submit(Survey survey, List<SurveyQuestion> questions) async {
    setState(() => _submitting = true);
    try {
      if (!_formKey.currentState!.validate()) {
        setState(() => _submitting = false);
        return;
      }

      // GPS is mandatory (hard requirement)
      if (_gps == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن الإرسال بدون GPS')));
        setState(() => _submitting = false);
        return;
      }

      final auth = ref.read(firebaseAuthProvider);
      final uid = auth.currentUser!.uid;
      final name = ref.read(myNameProvider);

      // Clean answers: remove deleted questions keys
      final activeQuestionIds = questions.where((q) => !q.isDeleted).map((q) => q.id).toSet();
      _answers.removeWhere((k, _) => !activeQuestionIds.contains(k));

      final responseId = _uuid.v4();
      await ref.read(responseRepositoryProvider).submitResponse(
            responseId: responseId,
            surveyId: survey.id,
            surveyVersion: survey.version,
            enteredByUid: uid,
            enteredByName: name,
            answers: Map<String, dynamic>.from(_answers),
            location: _gps!,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الاستبيان')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإرسال: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surveyDoc = ref.watch(firestoreProvider).collection('surveys').doc(widget.surveyId);

    return StreamBuilder(
      stream: surveyDoc.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return ErrorScaffold(message: 'خطأ: ${snap.error}');
        if (!snap.hasData) return const LoadingScaffold();
        final survey = Survey.fromDoc(snap.data! as dynamic);

        final qStream = ref.watch(surveyRepositoryProvider).watchQuestions(widget.surveyId);
        return StreamBuilder<List<SurveyQuestion>>(
          stream: qStream,
          builder: (context, qSnap) {
            if (qSnap.hasError) return ErrorScaffold(message: 'خطأ: ${qSnap.error}');
            if (!qSnap.hasData) return const LoadingScaffold();
            final questionsAll = qSnap.data!;
            final questions = questionsAll.where((q) => !q.isDeleted).toList();

            return Scaffold(
              appBar: AppBar(title: Text(survey.title.isEmpty ? 'استبيان' : survey.title)),
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('GPS إلزامي لإرسال الاستبيان'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: _submitting ? null : _captureGps,
                                  icon: const Icon(Icons.my_location),
                                  label: Text(_gps == null ? 'التقاط الموقع' : 'تحديث الموقع'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _gps == null
                                        ? (_gpsError == null ? 'لم يتم التقاط الموقع بعد' : _gpsError!)
                                        : 'lat=${_gps!.lat.toStringAsFixed(6)}, lng=${_gps!.lng.toStringAsFixed(6)} (±${(_gps!.accuracy ?? 0).toStringAsFixed(0)}m)',
                                  ),
                                ),
                              ],
                            ),
                            if (_gps != null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: LocationActions(
                                  location: LocationLite(
                                    lat: _gps!.lat,
                                    lng: _gps!.lng,
                                    accuracy: _gps!.accuracy,
                                  ),
                                  sheetTitle: 'موقع الاستبيان',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView.separated(
                          itemCount: questions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) => _QuestionCard(
                            question: questions[i],
                            onChanged: (val) => _answers[questions[i].id] = val,
                            currentValue: _answers[questions[i].id],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : () => _submit(survey, questionsAll),
                        child: Text(_submitting ? '...' : 'إرسال'),
                      ),
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

class _QuestionCard extends StatefulWidget {
  final SurveyQuestion question;
  final void Function(dynamic value) onChanged;
  final dynamic currentValue;

  const _QuestionCard({
    required this.question,
    required this.onChanged,
    required this.currentValue,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  dynamic _value;

  @override
  void initState() {
    super.initState();
    _value = widget.currentValue;
  }

  @override
  void didUpdateWidget(covariant _QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent provides a new value (rare), keep in sync.
    if (oldWidget.currentValue != widget.currentValue) {
      _value = widget.currentValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;

    Widget child;
    switch (q.type) {
      case QuestionType.text:
        child = TextFormField(
          initialValue: (_value ?? '') as String,
          decoration: InputDecoration(labelText: q.label),
          validator: (v) {
            if (q.required && (v == null || v.trim().isEmpty)) return 'هذا السؤال إجباري';
            return null;
          },
          onChanged: (v) {
            _value = v.trim();
            widget.onChanged(_value);
          },
        );
        break;

      case QuestionType.singleChoice:
        final selected = _value as String?;
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...q.options.map((opt) {
              return RadioListTile<String>(
                value: opt,
                groupValue: selected,
                title: Text(opt),
                onChanged: (v) {
                  setState(() => _value = v);
                  widget.onChanged(_value);
                },
              );
            }),
            if (q.required)
              FormField<String>(
                validator: (_) => (q.required && (selected == null || selected.isEmpty)) ? 'هذا السؤال إجباري' : null,
                builder: (state) => state.hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(state.errorText!, style: const TextStyle(color: Colors.red)),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        );
        break;

      case QuestionType.multiChoice:
      case QuestionType.checkbox:
        final current = (_value is List) ? List<String>.from(_value as List) : <String>[];
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...q.options.map((opt) {
              final checked = current.contains(opt);
              return CheckboxListTile(
                value: checked,
                title: Text(opt),
                onChanged: (v) {
                  final next = List<String>.from(current);
                  if (v == true) {
                    if (!next.contains(opt)) next.add(opt);
                  } else {
                    next.remove(opt);
                  }
                  setState(() => _value = next);
                  widget.onChanged(_value);
                },
              );
            }),
            if (q.required)
              FormField<List<String>>(
                validator: (_) => (q.required && current.isEmpty) ? 'هذا السؤال إجباري' : null,
                builder: (state) => state.hasError
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(state.errorText!, style: const TextStyle(color: Colors.red)),
                      )
                    : const SizedBox.shrink(),
              ),
          ],
        );
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
