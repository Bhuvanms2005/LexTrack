import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/case_database.dart';
import '../screens/login_screen.dart';
import '../screens/case_list_screen.dart';
import '../screens/todays_hearings_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {

  int todayHearings = 0;
  int totalCases = 0;
  int completedCases = 0;

  String userName = "";

  bool isLoading = true;

  List<String> notes = [];
  TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStats();
    loadUser();
    loadNotes();
  }

  void loadStats() async {

    final hearings = await CaseDatabase.getTodayHearingsCount();
    final cases = await CaseDatabase.getCases();

    int completed = 0;

    for (var c in cases) {
      if (c['status'] == "Completed") {
        completed++;
      }
    }

    if (!mounted) return;

    setState(() {
      todayHearings = hearings;
      totalCases = cases.length;
      completedCases = completed;
      isLoading = false;
    });
  }

  void loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      userName = prefs.getString("name") ?? "User";
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", false);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    notes = prefs.getStringList("daily_notes") ?? [];

    if (!mounted) return;
    setState(() {});
  }

  void addNote() async {
    if (noteController.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    notes.add(noteController.text.trim());
    await prefs.setStringList("daily_notes", notes);

    noteController.clear();

    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF162F4A),
        title: Row(
          children: const [
            Icon(Icons.balance, color: Color(0xFFC9A227)),
            SizedBox(width: 10),
            Text(
              "LexTrack",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        actions: [

          FutureBuilder<int>(
  future: CaseDatabase.getTodayHearingsCount(),
  builder: (context, snapshot) {

    int count = snapshot.data ?? 0;

    return Stack(
      children: [

        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificationScreen(),
              ),
            );
          },
        ),

        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),

      ],
    );
  },
),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onSelected: (value) {
              if (value == "logout") logout();

              if (value == "profile") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                ).then((_) => loadUser());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "profile",
                child: Text("Edit Profile"),
              ),
              PopupMenuItem(
                value: "logout",
                child: Text("Logout"),
              ),
            ],
          ),

          const SizedBox(width: 10),
        ],
      ),

      backgroundColor: const Color(0xFF1E3A5F),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CaseListScreen(),
                                ),
                              );
                            },
                            child: statCard("Total Cases", "$totalCases", Icons.folder_open),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: statCard("Completed", "$completedCases", Icons.check_circle),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TodaysHearingsScreen(),
                                ),
                              );
                            },
                            child: statCard("Today", "$todayHearings", Icons.today),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 25),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Welcome, $userName",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Daily Planner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: noteController,
                            decoration: InputDecoration(
                              hintText: "Add note...",
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC9A227),
                          ),
                          onPressed: addNote,
                          child: const Text("Add"),
                        )
                      ],
                    ),

                    const SizedBox(height: 15),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(notes[index]),
                          ),
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
    );
  }

  Widget statCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFC9A227)),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}