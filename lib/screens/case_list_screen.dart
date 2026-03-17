import 'package:flutter/material.dart';
import '../database/case_database.dart';
import 'case_details_screen.dart';
import '../widgets/app_drawer.dart';

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});

  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {

  List<Map<String,dynamic>> cases = [];
  List<Map<String,dynamic>> filteredCases = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCases();
  }

  void loadCases() async {
    final data = await CaseDatabase.getCases();

    setState(() {
      cases = data;
      filteredCases = data;
    });
  }

  void searchCases(String query) {

    query = query.toLowerCase();

    setState(() {
      filteredCases = cases.where((c) {
        return c['caseNumber'].toString().contains(query) ||
            c['clientName'].toLowerCase().contains(query) ||
            c['opponentName'].toLowerCase().contains(query) ||
            c['courtName'].toLowerCase().contains(query) ||
            c['caseType'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case List"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
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

          Expanded(
            child: filteredCases.isEmpty
                ? const Center(
                    child: Text(
                      "No results found",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
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

                            title: Text(
                              "${caseItem['caseNumber']}/${caseItem['year']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text("Client: ${caseItem['clientName']}"),

                                Text("Court: ${caseItem['courtName']}"),

                                Text("Next Hearing: ${caseItem['hearingDate']}"),

                              ],
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CaseDetailsScreen(caseItem: caseItem),
                                ),
                              );
                            },

                          ),
                        ),
                      );
                    },
                  ),
          ),

        ],
      ),
    );
  }
}