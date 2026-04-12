import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/judgement_service.dart';

class JudgementSearchScreen extends StatefulWidget {
  const JudgementSearchScreen({super.key});

  @override
  State<JudgementSearchScreen> createState() => _JudgementSearchScreenState();
}

class _JudgementSearchScreenState extends State<JudgementSearchScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> results = [];
  bool isLoading = false;
  bool hasSearched = false;

  void searchJudgements() async {
    String query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        hasSearched = false;
        results = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    try {
      List<Map<String, String>> fetchedResults =
          await JudgementService.fetchJudgements(query);

      setState(() {
        results = fetchedResults;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open the link")),
      );
      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Judgement"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Enter case / keyword",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => searchJudgements(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A227),
                  ),
                  onPressed: searchJudgements,
                  child: const Text("Search"),
                )
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !hasSearched
                      ? const Center(
                          child: Text(
                            "Search for legal judgements",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : results.isEmpty
                          ? const Center(
                              child: Text(
                                "No results found",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final item = results[index];

                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["title"] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item["link"] ?? "",
                                        style: const TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment:
                                            Alignment.centerRight,
                                        child: ElevatedButton(
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF1E3A5F),
                                          ),
                                          onPressed: item["link"] ==
                                                      null ||
                                                  item["link"]!.isEmpty
                                              ? null
                                              : () {
                                                  openLink(
                                                      item["link"]!);
                                                },
                                          child: const Text("Open"),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
            )
          ],
        ),
      ),
    );
  }
}