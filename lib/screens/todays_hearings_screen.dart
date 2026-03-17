import 'package:flutter/material.dart';
import '../database/case_database.dart';
import '../widgets/app_drawer.dart';

class TodaysHearingsScreen extends StatefulWidget {
  const TodaysHearingsScreen({super.key});

  @override
  State<TodaysHearingsScreen> createState() => _TodaysHearingsScreenState();
}

class _TodaysHearingsScreenState extends State<TodaysHearingsScreen> {

  List<Map<String,dynamic>> hearings = [];

  @override
  void initState() {
    super.initState();
    loadHearings();
  }

  void loadHearings() async {

    List<Map<String,dynamic>> allHearings =
        await CaseDatabase.getAllHearingsWithCase();

    String today =
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

    hearings = allHearings.where((h) {
      return h['date'] == today;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Today's Hearings"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),

      drawer: const AppDrawer(),

      backgroundColor: const Color(0xFF1E3A5F),

      body: hearings.isEmpty
          ? const Center(
              child: Text(
                "No hearings today",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hearings.length,
              itemBuilder: (context, index) {

                final h = hearings[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  child: ListTile(

                    title: Text(
                      "${h['caseNumber']}/${h['year']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text("Client: ${h['clientName']}"),
                        Text("Court: ${h['courtName']}"),
                        Text("Stage: ${h['stage']}"),

                      ],
                    ),

                  ),
                );

              },
            ),
    );
  }
}