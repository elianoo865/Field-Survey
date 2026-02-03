import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/providers.dart';
import 'auth_shell.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      if (!_formKey.currentState!.validate()) {
        setState(() => _loading = false);
        return;
      }

      await ref.read(authRepositoryProvider).register(
            name: _name.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );

      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = 'فشل إنشاء الحساب: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'إنشاء حساب',
      subtitle: 'أنشئ حسابك ثم اطلب من الأدمن تفعيل الدور المناسب لك',
      footer: TextButton(
        onPressed: _loading ? null : () => context.go('/login'),
        child: const Text('لديك حساب؟ تسجيل الدخول'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل البريد' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
              validator: (v) => (v == null || v.length < 6) ? 'على الأقل 6 أحرف' : null,
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _submit,
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(_loading ? '...' : 'إنشاء'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
