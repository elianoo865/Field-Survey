import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/providers.dart';
import 'auth_shell.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
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

      await ref.read(authRepositoryProvider).signIn(
            email: _email.text.trim(),
            password: _password.text,
          );

      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = 'فشل تسجيل الدخول: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'تسجيل الدخول',
      subtitle: 'ادخل بحسابك للوصول إلى لوحة الاستبيانات',
      footer: TextButton(
        onPressed: _loading ? null : () => context.go('/register'),
        child: const Text('إنشاء حساب جديد'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              validator: (v) => (v == null || v.isEmpty) ? 'أدخل كلمة المرور' : null,
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
                icon: const Icon(Icons.login),
                label: Text(_loading ? '...' : 'دخول'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
