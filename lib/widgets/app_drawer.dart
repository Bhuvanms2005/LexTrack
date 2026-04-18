import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/dashboard_screen.dart';
import '../screens/add_case_screen.dart';
import '../screens/todays_hearings_screen.dart';
import '../screens/case_list_screen.dart';
import '../screens/judgement_search_screen.dart';
import '../screens/login_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String userName = "Advocate";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString("name") ?? "Advocate";
      userEmail = prefs.getString("email") ?? "";
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF162F4A),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFFC9A227),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "A",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userEmail),
          ),

          _drawerItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const DashboardScreen()),
            ),
          ),

          _drawerItem(
            icon: Icons.folder_open,
            title: "Case List",
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const CaseListScreen()),
            ),
          ),

          _drawerItem(
            icon: Icons.add_circle_outline,
            title: "Add Case",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCaseScreen()),
            ),
          ),

          _drawerItem(
            icon: Icons.today,
            title: "Today's Hearings",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TodaysHearingsScreen()),
            ),
          ),

          _drawerItem(
            icon: Icons.search,
            title: "Search Judgement",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const JudgementSearchScreen()),
            ),
          ),

          const Spacer(),
          const Divider(),

          _drawerItem(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF162F4A)),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 10,
    );
  }
}