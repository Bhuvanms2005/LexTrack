import 'package:fl_chart/fl_chart.dart';
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
  int pendingCases = 0;

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

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void loadStats() async {
    final hearings = await CaseDatabase.getTodayHearingsCount();
    final cases = await CaseDatabase.getCases();

    int completed = 0;
    for (var c in cases) {
      if (c['status'] == "Completed") completed++;
    }

    if (!mounted) return;

    setState(() {
      todayHearings = hearings;
      totalCases = cases.length;
      completedCases = completed;
      pendingCases = totalCases - completedCases;
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
    String today = DateTime.now().toIso8601String().split('T')[0];
    String? savedDate = prefs.getString("notes_date");

    if (savedDate != today) {
      await prefs.remove("daily_notes");
      await prefs.setString("notes_date", today);
      notes = [];
    } else {
      notes = prefs.getStringList("daily_notes") ?? [];
    }

    if (!mounted) return;
    setState(() {});
  }

  void addNote() async {
    if (noteController.text.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().split('T')[0];
    await prefs.setString("notes_date", today);
    notes.add(noteController.text.trim());
    await prefs.setStringList("daily_notes", notes);

    noteController.clear();
    if (!mounted) return;
    setState(() {});
  }

  void deleteNote(int index) async {
    final prefs = await SharedPreferences.getInstance();
    notes.removeAt(index);
    await prefs.setStringList("daily_notes", notes);
    if (!mounted) return;
    setState(() {});
  }

  Widget buildCaseStatusChart() {
    if (totalCases == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            "No cases yet. Add your first case!",
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: completedCases.toDouble(),
              color: const Color(0xFF4CAF50),
              title: completedCases > 0 ? "$completedCases" : "",
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            PieChartSectionData(
              value: pendingCases.toDouble(),
              color: const Color(0xFFE53935),
              title: pendingCases > 0 ? "$pendingCases" : "",
              radius: 60,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLegend(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF162F4A),
        title: const Row(
          children: [
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
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ).then((_) => loadUser());
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "profile", child: Text("Edit Profile")),
              PopupMenuItem(value: "logout", child: Text("Logout")),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: () async {
                loadStats();
                loadUser();
                loadNotes();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome text
                      Text(
                        "Welcome, $userName 👋",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CaseListScreen(),
                                ),
                              ),
                              child: statCard(
                                "Total Cases",
                                "$totalCases",
                                Icons.folder_open,
                                const Color(0xFF1565C0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: statCard(
                              "Completed",
                              "$completedCases",
                              Icons.check_circle_outline,
                              const Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TodaysHearingsScreen(),
                                ),
                              ),
                              child: statCard(
                                "Today",
                                "$todayHearings",
                                Icons.today,
                                const Color(0xFF6A1B9A),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Pending cases card (full width)
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CaseListScreen(),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: pendingCases > 0
                                ? const Color(0xFFB71C1C).withOpacity(0.85)
                                : Colors.green.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                pendingCases > 0
                                    ? Icons.pending_actions
                                    : Icons.done_all,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$pendingCases Pending Cases",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    pendingCases > 0
                                        ? "Tap to view pending cases"
                                        : "All cases completed!",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Chart
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF162F4A),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Case Status Overview",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            buildCaseStatusChart(),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildLegend(
                                    const Color(0xFF4CAF50), "Completed"),
                                buildLegend(const Color(0xFFE53935), "Pending"),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Daily Planner
                      const Text(
                        "Daily Planner",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: noteController,
                              onSubmitted: (_) => addNote(),
                              decoration: InputDecoration(
                                hintText: "Add a task for today...",
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC9A227),
                              ),
                              onPressed: addNote,
                              child: const Text("Add"),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (notes.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF162F4A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "No tasks for today. Add one above!",
                            style: TextStyle(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.check_box_outline_blank,
                                  color: Color(0xFFC9A227),
                                ),
                                title: Text(
                                  notes[index],
                                  style: const TextStyle(fontSize: 15),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 20),
                                  onPressed: () => deleteNote(index),
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget statCard(
      String title, String count, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          top: BorderSide(color: accentColor, width: 3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 26),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}