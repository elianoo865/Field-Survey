import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0F0F2D), Color(0xFF2A1650)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                    ),
                    child: SvgPicture.asset('assets/brand/logo.svg'),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: cs.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: child,
                    ),
                  ),
                  if (footer != null) ...[
                    const SizedBox(height: 10),
                    footer!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
