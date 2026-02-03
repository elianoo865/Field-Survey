import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../firebase_options.dart';
import 'app.dart';

class FieldSurveyBootstrap extends ConsumerStatefulWidget {
  const FieldSurveyBootstrap({super.key});

  @override
  ConsumerState<FieldSurveyBootstrap> createState() => _FieldSurveyBootstrapState();
}

class _FieldSurveyBootstrapState extends ConsumerState<FieldSurveyBootstrap> {
  late final Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = _initialize();
  }

  Future<void> _initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable offline persistence (mobile + web IndexedDB when supported)
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

    // Small delay so the splash feels intentional (and avoids a flash on fast devices).
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init,
      builder: (context, snap) {
        if (snap.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'فشل تشغيل التطبيق\n\n${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        if (snap.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        return const FieldSurveyApp();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF0F0F2D),
                  Color(0xFF2A1650),
                ],
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: Colors.white.withOpacity(0.14)),
                      ),
                      child: SvgPicture.asset('assets/brand/logo.svg'),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Field Survey',
                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'جاري التحميل…',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 22),
                    const SizedBox(width: 28, height: 28, child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
