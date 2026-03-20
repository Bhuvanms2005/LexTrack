import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'case_list_screen.dart';
import 'add_case_screen.dart';
import 'todays_hearings_screen.dart';
import 'judgement_search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  final GlobalKey<CaseListScreenState> caseListKey = GlobalKey<CaseListScreenState>();
  final GlobalKey<DashboardScreenState> dashboardKey = GlobalKey<DashboardScreenState>();

  late final List<Widget> screens = [
     DashboardScreen(key: dashboardKey),
    CaseListScreen(key: caseListKey),
    const SizedBox(),
    const TodaysHearingsScreen(),
    const JudgementSearchScreen(),
  ];

  void onItemTapped(int index) async {

    if (index == 2) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AddCaseScreen(),
        ),
      );

      if (result == true) {
        caseListKey.currentState?.loadCases();
        dashboardKey.currentState?.loadStats();
        setState(() {
          selectedIndex = 1;
        });
      }

      return;
    }

    setState(() {
      selectedIndex = index;
    });
    if (index == 0) {
  dashboardKey.currentState?.loadStats();
}
    if (index == 1) {
      caseListKey.currentState?.loadCases();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFC9A227),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            label: "Cases",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: "Hearings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
        ],
      ),
    );
  }
}