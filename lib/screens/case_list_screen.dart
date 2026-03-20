import 'package:flutter/material.dart';
import '../database/case_database.dart';
import 'case_details_screen.dart';

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => CaseListScreenState();
}

class CaseListScreenState extends State<CaseListScreen> {

  List<Map<String,dynamic>> cases = [];
  List<Map<String,dynamic>> filteredCases = [];

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
      filteredCases = cases;
    } else {
      filteredCases = cases.where((c) {
        return (c['status'] ?? "Pending") == selectedFilter;
      }).toList();
    }
  }

  void searchCases(String query) {

    query = query.trim().toLowerCase();

    List<Map<String,dynamic>> temp = cases.where((c) {
      return c['caseNumber'].toString().toLowerCase().contains(query) ||
          (c['clientName']?.toLowerCase().contains(query) ?? false) ||
          (c['opponentName']?.toLowerCase().contains(query) ?? false) ||
          (c['courtName']?.toLowerCase().contains(query) ?? false) ||
          (c['caseType']?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (selectedFilter != "All") {
      temp = temp.where((c) => (c['status'] ?? "Pending") == selectedFilter).toList();
    }

    setState(() {
      filteredCases = temp;
    });
  }

  Widget filterButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedFilter == label
            ? const Color(0xFFC9A227)
            : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          selectedFilter = label;
          applyFilter();
        });
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case List"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              onChanged: searchCases,
              decoration: InputDecoration(
                hintText: "Search cases...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                filterButton("All"),
                filterButton("Pending"),
                filterButton("Completed"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: filteredCases.isEmpty
                ? const Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      loadCases();
                    },
                    child: ListView.builder(
                      itemCount: filteredCases.length,
                      itemBuilder: (context, index) {

                        final caseItem = filteredCases[index];

                        return Padding(
                          padding: const EdgeInsets.all(10),

                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: ListTile(

                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${caseItem['caseNumber']}/${caseItem['year']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    caseItem['status'] ?? "Pending",
                                    style: TextStyle(
                                      color: (caseItem['status'] == "Completed")
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text("Client: ${caseItem['clientName'] ?? ''}"),

                                  Text("Court: ${caseItem['courtName'] ?? ''}"),

                                  Text("Next Hearing: ${formatDate(caseItem['hearingDate'])}"),

                                ],
                              ),

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
}