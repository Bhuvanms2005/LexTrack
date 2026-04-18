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
  String? errorMessage;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void searchJudgements() async {
    String query = searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        hasSearched = false;
        results = [];
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
      errorMessage = null;
    });

    try {
      List<Map<String, String>> fetchedResults =
          await JudgementService.fetchJudgements(query);

      setState(() {
        results = fetchedResults;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        results = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> openInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open this link")),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openKanoonSearch(String query) async {
    final encoded = Uri.encodeComponent(query);
    final url = "https://indiankanoon.org/search/?formInput=$encoded";
    await openInBrowser(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Judgement Search"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Enter case / keyword / act...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => searchJudgements(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A227),
                    ),
                    onPressed: searchJudgements,
                    child: const Text("Search"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Open in browser fallback
            if (searchController.text.isNotEmpty)
              InkWell(
                onTap: () => openKanoonSearch(searchController.text),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_browser,
                          color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Open search directly in Indian Kanoon →",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Results area
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.white))
                  : errorMessage != null
                      ? _errorState()
                      : !hasSearched
                          ? _initialState()
                          : results.isEmpty
                              ? _noResultsState()
                              : ListView.builder(
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    final item = results[index];
                                    return _resultCard(item);
                                  },
                                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.balance, size: 64, color: Colors.white30),
          SizedBox(height: 16),
          Text(
            "Search legal judgements",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Search by case name, act, or keyword\non Indian Kanoon",
            style: TextStyle(color: Colors.white54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _noResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.white30),
          const SizedBox(height: 16),
          const Text(
            "No results found",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A227)),
            onPressed: () =>
                openKanoonSearch(searchController.text),
            icon: const Icon(Icons.open_in_browser),
            label: const Text("Open in Indian Kanoon"),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.white30),
          const SizedBox(height: 16),
          const Text(
            "Could not fetch results",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Indian Kanoon may be blocking direct access.\nTry opening in browser instead.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A227)),
            onPressed: () =>
                openKanoonSearch(searchController.text),
            icon: const Icon(Icons.open_in_browser),
            label: const Text("Open in Browser"),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item["title"] ?? "",
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            item["link"] ?? "",
            style: const TextStyle(color: Colors.blue, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF162F4A),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
              ),
              onPressed: (item["link"] == null || item["link"]!.isEmpty)
                  ? null
                  : () => openInBrowser(item["link"]!),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text("Open"),
            ),
          ),
        ],
      ),
    );
  }
}