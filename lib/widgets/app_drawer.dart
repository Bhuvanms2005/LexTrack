import 'package:flutter/material.dart';
import 'package:lextrack/screens/dashboard_screen.dart';
import '../screens/add_case_screen.dart';
import '../screens/todays_hearings_screen.dart';
import '../screens/case_list_screen.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [

          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF162F4A),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFFC9A227),
                size: 35,
              ),
            ),
            accountName: const Text("Advocate Name"),
            accountEmail: const Text("advocate@email.com"),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder:(context)=>const DashboardScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text("Add Case"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=> const AddCaseScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text("Case List"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:(context)=> const CaseListScreen(),
                ),
              );
            },
          ),

          ListTile(
          leading: const Icon(Icons.today),
          title: const Text("Today's Hearings"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TodaysHearingsScreen(),
              ),
            );
          },
        ),
          ListTile(
              leading:const Icon(Icons.search),
              title: const Text("Search Judgement"),
              onTap:(){},
            ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text("Clients"),
            onTap: () {},
          ),

          const Spacer(),

          const Divider(),
          ListTile(
              leading:const Icon(Icons.settings),
              title:const Text("Settings"),
              onTap:(){},
            ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {},
          )

        ],
      ),
    );
  }
}