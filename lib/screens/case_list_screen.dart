import 'package:flutter/material.dart';
import '../database/case_database.dart';
import 'case_details_screen.dart';

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => CaseListScreenState();
}

class CaseListScreenState extends State<CaseListScreen> {
  List<Map<String, dynamic>> cases = [];
  List<Map<String, dynamic>> filteredCases = [];

  TextEditingController searchController = TextEditingController();
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    loadCases();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadCases();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void loadCases() async {
    final data = await CaseDatabase.getCases();
    if (!mounted) return;
    cases = data;
    applyFilter();
    setState(() {});
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    try {
      DateTime d = DateTime.parse(date);
      return "${d.day}/${d.month}/${d.year}";
    } catch (e) {
      return date;
    }
  }

  void applyFilter() {
    if (selectedFilter == "All") {
      filteredCases = List.from(cases);
    } else {
      filteredCases = cases
          .where((c) => (c['status'] ?? "Pending") == selectedFilter)
          .toList();
    }
  }

  void searchCases(String query) {
    query = query.trim().toLowerCase();

    List<Map<String, dynamic>> temp = cases.where((c) {
      return c['caseNumber'].toString().toLowerCase().contains(query) ||
          (c['clientName']?.toLowerCase().contains(query) ?? false) ||
          (c['opponentName']?.toLowerCase().contains(query) ?? false) ||
          (c['courtName']?.toLowerCase().contains(query) ?? false) ||
          (c['caseType']?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (selectedFilter != "All") {
      temp = temp
          .where((c) => (c['status'] ?? "Pending") == selectedFilter)
          .toList();
    }

    setState(() {
      filteredCases = temp;
    });
  }

  Widget filterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
          if (searchController.text.isNotEmpty) {
            searchCases(searchController.text);
          } else {
            applyFilter();
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC9A227) : Colors.white24,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC9A227)
                : Colors.white38,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cases"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: searchController,
              onChanged: searchCases,
              decoration: InputDecoration(
                hintText: "Search by case no., client, court...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                          applyFilter();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                filterChip("All"),
                const SizedBox(width: 8),
                filterChip("Pending"),
                const SizedBox(width: 8),
                filterChip("Completed"),
                const Spacer(),
                Text(
                  "${filteredCases.length} case${filteredCases.length != 1 ? 's' : ''}",
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Case list
          Expanded(
            child: filteredCases.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchController.text.isNotEmpty
                              ? Icons.search_off
                              : Icons.folder_open,
                          size: 64,
                          color: Colors.white30,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchController.text.isNotEmpty
                              ? "No cases match your search"
                              : selectedFilter == "All"
                                  ? "No cases yet.\nTap + to add your first case."
                                  : "No $selectedFilter cases",
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => loadCases(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      itemCount: filteredCases.length,
                      itemBuilder: (context, index) {
                        final caseItem = filteredCases[index];
                        final bool isCompleted =
                            caseItem['status'] == "Completed";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CaseDetailsScreen(caseItem: caseItem),
                                ),
                              );
                              loadCases();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border(
                                  left: BorderSide(
                                    color: isCompleted
                                        ? Colors.green
                                        : Colors.red,
                                    width: 5,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${caseItem['caseNumber']}/${caseItem['year']}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isCompleted
                                                ? Colors.green.shade50
                                                : Colors.red.shade50,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isCompleted
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                          child: Text(
                                            caseItem['status'] ?? "Pending",
                                            style: TextStyle(
                                              color: isCompleted
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _infoRow(Icons.person_outline,
                                        caseItem['clientName'] ?? '—'),
                                    const SizedBox(height: 4),
                                    _infoRow(Icons.account_balance,
                                        caseItem['courtName'] ?? '—'),
                                    const SizedBox(height: 4),
                                    _infoRow(
                                      Icons.event,
                                      "Next: ${formatDate(caseItem['hearingDate'])}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}