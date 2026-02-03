import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/providers.dart';
import '../shared/loading_error.dart';
import 'surveys/admin_surveys_page.dart';
import 'users/admin_users_page.dart';
import 'responses/admin_responses_page.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(myNameProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin — $name'),
        actions: [
          IconButton(
            tooltip: 'تسجيل خروج',
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          AdminSurveysPage(),
          AdminResponsesPage(),
          AdminUsersPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'الاستبيانات'),
          NavigationDestination(icon: Icon(Icons.table_view), label: 'النتائج'),
          NavigationDestination(icon: Icon(Icons.people), label: 'المستخدمين'),
        ],
      ),
    );
  }
}
