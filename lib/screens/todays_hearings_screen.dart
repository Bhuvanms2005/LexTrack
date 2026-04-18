import 'package:flutter/material.dart';
import '../database/case_database.dart';
import 'case_details_screen.dart';

class TodaysHearingsScreen extends StatefulWidget {
  const TodaysHearingsScreen({super.key});

  @override
  State<TodaysHearingsScreen> createState() => _TodaysHearingsScreenState();
}

class _TodaysHearingsScreenState extends State<TodaysHearingsScreen> {
  List<Map<String, dynamic>> hearings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHearings();
  }

  void loadHearings() async {
    setState(() => isLoading = true);

    List<Map<String, dynamic>> allHearings =
        await CaseDatabase.getAllHearingsWithCase();

    String today =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    hearings = allHearings.where((h) => h['date'] == today).toList();

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${now.day} ${months[now.month]}, ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Hearings"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadHearings,
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: () async => loadHearings(),
              child: hearings.isEmpty
                  ? ListView(
                      // Needed for pull-to-refresh to work on empty list
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event_available,
                                  size: 70, color: Colors.white30),
                              const SizedBox(height: 16),
                              Text(
                                "No hearings today",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _todayLabel(),
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFFC9A227), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _todayLabel(),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC9A227),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "${hearings.length} hearing${hearings.length != 1 ? 's' : ''}",
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: hearings.length,
                            itemBuilder: (context, index) {
                              final h = hearings[index];

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: const Border(
                                    left: BorderSide(
                                        color: Color(0xFFC9A227), width: 5),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  title: Text(
                                    "${h['caseNumber']}/${h['year']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      _row(Icons.person_outline,
                                          h['clientName'] ?? '—'),
                                      _row(Icons.account_balance,
                                          h['courtName'] ?? '—'),
                                      _row(Icons.gavel,
                                          "Stage: ${h['stage'] ?? '—'}"),
                                    ],
                                  ),
                                  trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Colors.black45),
                                  onTap: () async {
                                    // Load the full case and navigate
                                    final fullCase = await CaseDatabase
                                        .getCase(h['caseId']);
                                    if (!mounted) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CaseDetailsScreen(
                                            caseItem: fullCase),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.black45),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}