import 'package:flutter/material.dart';
import '../database/case_database.dart';
import 'case_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  List<Map<String,dynamic>> todayCases = [];
  List<Map<String,dynamic>> pendingCases = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  void loadNotifications() async {

    final cases = await CaseDatabase.getCases();
    final todayList = await CaseDatabase.getTodayHearingsWithCase();

    List<Map<String,dynamic>> pending = [];

    for (var c in cases) {
      if (c['status'] != "Completed") {
        pending.add(c);
      }
    }

    if (!mounted) return;

    setState(() {
      todayCases = todayList;
      pendingCases = pending;
      isLoading = false;
    });
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget caseTile(Map<String,dynamic> c) {
    return Card(
      child: ListTile(
        title: Text("${c['caseNumber']}/${c['year']}"),
        subtitle: Text(c['clientName'] ?? ""),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CaseDetailsScreen(caseItem: c),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  sectionTitle("Today's Hearings"),

                  const SizedBox(height: 10),

                  todayCases.isEmpty
                      ? const Text("No hearings today", style: TextStyle(color: Colors.white))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todayCases.length,
                          itemBuilder: (context, index) {
                            return caseTile(todayCases[index]);
                          },
                        ),

                  const SizedBox(height: 20),

                  sectionTitle("Pending Cases"),

                  const SizedBox(height: 10),

                  pendingCases.isEmpty
                      ? const Text("No pending cases", style: TextStyle(color: Colors.white))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingCases.length,
                          itemBuilder: (context, index) {
                            return caseTile(pendingCases[index]);
                          },
                        ),

                ],
              ),
            ),
    );
  }
}