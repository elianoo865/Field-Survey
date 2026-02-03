import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import 'surveys/published_surveys_page.dart';
import 'surveys/my_responses_page.dart';

class SurveyorHomePage extends ConsumerStatefulWidget {
  const SurveyorHomePage({super.key});

  @override
  ConsumerState<SurveyorHomePage> createState() => _SurveyorHomePageState();
}

class _SurveyorHomePageState extends ConsumerState<SurveyorHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(myNameProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Surveyor — $name'),
        actions: [
          IconButton(
            tooltip: 'تسجيل خروج',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          PublishedSurveysPage(),
          MyResponsesPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.assignment), label: 'الاستبيانات'),
          NavigationDestination(icon: Icon(Icons.history), label: 'إدخالاتي'),
        ],
      ),
    );
  }
}
