import 'package:flutter/material.dart';
import '../database/case_database.dart';
import '../widgets/app_drawer.dart';
import 'add_payment_screen.dart';
import 'add_hearing_screen.dart';
import 'add_note_screen.dart';
import 'edit_case_screen.dart';

class CaseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> caseItem;

  const CaseDetailsScreen({super.key, required this.caseItem});

  @override
  State<CaseDetailsScreen> createState() => _CaseDetailsScreenState();
}

class _CaseDetailsScreenState extends State<CaseDetailsScreen> {

  List<Map<String,dynamic>> hearings = [];
  List<Map<String,dynamic>> payments = [];
  List<Map<String,dynamic>> notes = [];

  int totalPaid = 0;

  Map<String,dynamic>? caseData;

  @override
  void initState() {
    super.initState();
    caseData = widget.caseItem;
    loadHistory();
  }

  void loadHistory() async {

    final updatedCase = await CaseDatabase.getCase(widget.caseItem['id']);

    hearings = await CaseDatabase.getHearings(widget.caseItem['id']);
    payments = await CaseDatabase.getPayments(widget.caseItem['id']);
    notes = await CaseDatabase.getNotes(widget.caseItem['id']);

    totalPaid = await CaseDatabase.getTotalPayments(widget.caseItem['id']);

    setState(() {
      caseData = updatedCase;
    });
  }

  @override
  Widget build(BuildContext context) {

    final data = caseData ?? widget.caseItem;

    int totalFee = int.tryParse(data['totalFee'].toString()) ?? 0;
    int remaining = totalFee - totalPaid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFF1E3A5F),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "${data['caseNumber']}/${data['year']}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  detailRow("Client", data['clientName']),
                  detailRow("Opponent", data['opponentName']),
                  detailRow("Court", data['courtName']),
                  detailRow("Case Type", data['caseType']),
                  detailRow("Next Hearing", data['hearingDate']),
                  detailRow("Total Fee", data['totalFee']),

                  const SizedBox(height: 20),

                  const Text(
                    "Notes",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${data['notes']}",
                    style: const TextStyle(fontSize: 16),
                  ),

                ],
              ),
            ),

            const SizedBox(height:20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Hearing History",
                style: TextStyle(
                    color: Colors.white,
                    fontSize:18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            const SizedBox(height:10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hearings.length,
              itemBuilder:(context,index){

                final h = hearings[index];

                return Card(
                  child: ListTile(
                    title: Text("${h['date']}  -  ${h['stage']}"),
                    subtitle: Text("Next Hearing: ${h['nextHearing']}"),
                  ),
                );

              },
            ),

            const SizedBox(height:20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Payment History",
                style: TextStyle(
                    color: Colors.white,
                    fontSize:18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            const SizedBox(height:10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              itemBuilder:(context,index){

                final p = payments[index];

                return Card(
                  child: ListTile(
                    title: Text("₹${p['amount']}  -  ${p['method']}"),
                    subtitle: Text("${p['date']}"),
                  ),
                );

              },
            ),

            const SizedBox(height:20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Case Notes",
                style: TextStyle(
                    color: Colors.white,
                    fontSize:18,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),

            const SizedBox(height:10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notes.length,
              itemBuilder:(context,index){

                final n = notes[index];

                return Card(
                  child: ListTile(
                    title: Text(n['note']),
                    subtitle: Text(n['date']),
                  ),
                );

              },
            ),

            const SizedBox(height:20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14)
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Total Fee: ₹$totalFee",
                    style: const TextStyle(fontSize:16),
                  ),

                  const SizedBox(height:5),

                  Text(
                    "Paid: ₹$totalPaid",
                    style: const TextStyle(fontSize:16),
                  ),

                  const SizedBox(height:5),

                  Text(
                    "Remaining: ₹$remaining",
                    style: const TextStyle(
                        fontSize:16,
                        fontWeight: FontWeight.bold
                    ),
                  )

                ],
              ),
            ),

            const SizedBox(height:20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [

                actionCard(Icons.event, "Add Hearing", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddHearingScreen(
                        caseId: data['id'],
                      ),
                    ),
                  ).then((_) => loadHistory());
                }),

                actionCard(Icons.payment, "Add Payment", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddPaymentScreen(caseId: data['id']),
                    ),
                  ).then((_) => loadHistory());
                }),

                actionCard(Icons.note_add, "Add Notes", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNoteScreen(
                        caseId: data['id'],
                      ),
                    ),
                  ).then((_) => loadHistory());
                }),

                actionCard(Icons.edit, "Edit Case", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCaseScreen(
                        caseItem: data,
                      ),
                    ),
                  ).then((_) => loadHistory());
                }),

              ],
            )

          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [

          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              "$value",
              style: const TextStyle(fontSize: 17),
            ),
          )

        ],
      ),
    );
  }

  Widget actionCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              size: 32,
              color: const Color(0xFFC9A227),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )

          ],
        ),
      ),
    );
  }
}