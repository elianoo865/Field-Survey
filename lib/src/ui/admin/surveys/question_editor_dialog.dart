import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models.dart';
import '../../../state/providers.dart';

class QuestionEditorDialog extends ConsumerStatefulWidget {
  final String surveyId;
  final String? questionId;

  final int initialOrder;
  final String? initialLabel;
  final QuestionType? initialType;
  final bool? initialRequired;
  final List<String>? initialOptions;
  final bool? initialIsDeleted;

  const QuestionEditorDialog({
    super.key,
    required this.surveyId,
    required this.initialOrder,
    this.questionId,
    this.initialLabel,
    this.initialType,
    this.initialRequired,
    this.initialOptions,
    this.initialIsDeleted,
  });

  @override
  ConsumerState<QuestionEditorDialog> createState() => _QuestionEditorDialogState();
}

class _QuestionEditorDialogState extends ConsumerState<QuestionEditorDialog> {
  late final TextEditingController _label;
  late QuestionType _type;
  late bool _required;
  late int _order;
  late bool _isDeleted;
  final _options = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _label = TextEditingController(text: widget.initialLabel ?? '');
    _type = widget.initialType ?? QuestionType.text;
    _required = widget.initialRequired ?? false;
    _order = widget.initialOrder;
    _isDeleted = widget.initialIsDeleted ?? false;

    final opts = widget.initialOptions ?? <String>[];
    if (opts.isEmpty) {
      _options.add(TextEditingController());
      _options.add(TextEditingController());
    } else {
      for (final o in opts) {
        _options.add(TextEditingController(text: o));
      }
    }
  }

  @override
  void dispose() {
    _label.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _needsOptions => _type == QuestionType.singleChoice || _type == QuestionType.multiChoice || _type == QuestionType.checkbox;

  Future<void> _save() async {
    final options = _needsOptions
        ? _options.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList()
        : <String>[];

    if (_needsOptions && options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل خيارين على الأقل')));
      return;
    }

    await ref.read(surveyRepositoryProvider).upsertQuestion(
          surveyId: widget.surveyId,
          questionId: widget.questionId,
          label: _label.text.trim(),
          type: _type,
          required: _required,
          order: _order,
          options: options,
          isDeleted: _isDeleted,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.questionId == null ? 'إضافة سؤال' : 'تعديل سؤال'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _label,
                decoration: const InputDecoration(labelText: 'نص السؤال'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<QuestionType>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: QuestionType.text, child: Text('Text')),
                  DropdownMenuItem(value: QuestionType.singleChoice, child: Text('اختيار واحد')),
                  DropdownMenuItem(value: QuestionType.multiChoice, child: Text('اختيار متعدد')),
                  DropdownMenuItem(value: QuestionType.checkbox, child: Text('Checkbox')),
                ],
                onChanged: (v) => setState(() => _type = v ?? QuestionType.text),
                decoration: const InputDecoration(labelText: 'نوع السؤال'),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _required,
                onChanged: (v) => setState(() => _required = v),
                title: const Text('Required (إجباري)'),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Order:'),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: _order.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _order = int.tryParse(v) ?? _order,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_needsOptions) ...[
                const Align(alignment: Alignment.centerLeft, child: Text('الخيارات')),
                const SizedBox(height: 6),
                ..._options.asMap().entries.map((e) {
                  final idx = e.key;
                  final c = e.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: c,
                            decoration: InputDecoration(labelText: 'خيار ${idx + 1}'),
                          ),
                        ),
                        IconButton(
                          tooltip: 'حذف خيار',
                          onPressed: _options.length <= 2
                              ? null
                              : () => setState(() {
                                    _options.removeAt(idx).dispose();
                                  }),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  );
                }),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _options.add(TextEditingController())),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة خيار'),
                  ),
                ),
              ],
              const SizedBox(height: 6),
              if (widget.questionId != null)
                SwitchListTile(
                  value: _isDeleted,
                  onChanged: (v) => setState(() => _isDeleted = v),
                  title: const Text('محذوف (Soft delete)'),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        FilledButton(onPressed: _save, child: const Text('حفظ')),
      ],
    );
  }
}
