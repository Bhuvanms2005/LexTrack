import 'package:flutter/material.dart';
import '../database/case_database.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  int todayHearings = 0;
  int pendingCases = 0;
  int pendingFees = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  void loadNotifications() async {

    final hearings = await CaseDatabase.getTodayHearingsCount();
    final cases = await CaseDatabase.getCases();
    final fees = await CaseDatabase.getTotalPendingFees();

    int pending = 0;

    for (var c in cases) {
      if (c['status'] != "Completed") {
        pending++;
      }
    }

    if (!mounted) return;

    setState(() {
      todayHearings = hearings;
      pendingCases = pending;
      pendingFees = fees;
      isLoading = false;
    });
  }

  Widget notificationCard(IconData icon, String title, String value) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC9A227)),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  notificationCard(
                    Icons.today,
                    "Today's Hearings",
                    "$todayHearings",
                  ),

                  notificationCard(
                    Icons.folder,
                    "Pending Cases",
                    "$pendingCases",
                  ),

                  notificationCard(
                    Icons.currency_rupee,
                    "Pending Fees",
                    "₹$pendingFees",
                  ),

                ],
              ),
            ),
    );
  }
}