import 'package:flutter/material.dart';
import '../database/case_database.dart';
import 'case_details_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> todayCases = [];
  List<Map<String, dynamic>> pendingCases = [];
  int pendingFees = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  void loadNotifications() async {
    final cases = await CaseDatabase.getCases();
    final todayList = await CaseDatabase.getTodayHearingsWithCase();
    final totalPendingFees = await CaseDatabase.getTotalPendingFees();

    List<Map<String, dynamic>> pending = cases
        .where((c) => c['status'] != "Completed")
        .toList();

    if (!mounted) return;

    setState(() {
      todayCases = todayList;
      pendingCases = pending;
      pendingFees = totalPendingFees;
      isLoading = false;
    });
  }

  Widget sectionHeader(String title, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC9A227), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFC9A227),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$count",
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget caseTile(Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF162F4A),
          child: Text(
            "${c['caseNumber']}".substring(0, 1),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(
          "${c['caseNumber']}/${c['year']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(c['clientName'] ?? ""),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.black45),
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

  Widget emptyNote(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white60)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadNotifications();
            },
          )
        ],
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: () async => loadNotifications(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pending fees banner
                    if (pendingFees > 0)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C1C).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.currency_rupee,
                                color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Pending Fees",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 13),
                                ),
                                Text(
                                  "₹$pendingFees outstanding",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // Today's hearings
                    sectionHeader(
                        "Today's Hearings", Icons.today, todayCases.length),
                    const SizedBox(height: 10),

                    todayCases.isEmpty
                        ? emptyNote("No hearings scheduled for today")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: todayCases.length,
                            itemBuilder: (context, index) =>
                                caseTile(todayCases[index]),
                          ),

                    const SizedBox(height: 24),

                    // Pending cases
                    sectionHeader(
                        "Pending Cases", Icons.pending_actions, pendingCases.length),
                    const SizedBox(height: 10),

                    pendingCases.isEmpty
                        ? emptyNote("No pending cases — great work!")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingCases.length,
                            itemBuilder: (context, index) =>
                                caseTile(pendingCases[index]),
                          ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}