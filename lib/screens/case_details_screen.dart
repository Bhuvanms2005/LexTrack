import 'package:flutter/material.dart';
import '../database/case_database.dart';
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

    final h = await CaseDatabase.getHearings(widget.caseItem['id']);
    final p = await CaseDatabase.getPayments(widget.caseItem['id']);
    final n = await CaseDatabase.getNotes(widget.caseItem['id']);
    final paid = await CaseDatabase.getTotalPayments(widget.caseItem['id']);

    if (!mounted) return;

    setState(() {
      caseData = updatedCase;
      hearings = h;
      payments = p;
      notes = n;
      totalPaid = paid;
    });
  }

  Future<void> updateStatus(String status) async {
    await CaseDatabase.updateCaseStatus(widget.caseItem['id'], status);
    loadHistory();
  }

  Future<void> deleteCase() async {
    await CaseDatabase.deleteCase(widget.caseItem['id']);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Case"),
          content: const Text("Are you sure you want to delete this case?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteCase();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Color getStatusColor(String status) {
    return status == "Completed" ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {

    final data = caseData ?? widget.caseItem;

    int totalFee = int.tryParse(data['totalFee'].toString()) ?? 0;
    int remaining = totalFee - totalPaid;

    String status = data['status'] ?? "Pending";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Details"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: confirmDelete,
          )
        ],
      ),
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

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Text("Status: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        status,
                        style: TextStyle(
                          color: getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 18),

                  detailRow("Client", data['clientName']),
                  detailRow("Opponent", data['opponentName']),
                  detailRow("Court", data['courtName']),
                  detailRow("Case Type", data['caseType']),
                  detailRow("Next Hearing", data['hearingDate']),
                  detailRow("Total Fee", data['totalFee']),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () => updateStatus("Completed"),
                          child: const Text("Mark Completed"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => updateStatus("Pending"),
                          child: const Text("Reopen"),
                        ),
                      ),
                    ],
                  ),

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

            sectionTitle("Hearing History"),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hearings.length,
              itemBuilder:(context,index){
                final h = hearings[index];
                return Card(
                  child: ListTile(
                    title: Text("${h['date']} - ${h['stage']}"),
                    subtitle: Text("Next: ${h['nextHearing']}"),
                  ),
                );
              },
            ),

            const SizedBox(height:20),

            sectionTitle("Payment History"),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: payments.length,
              itemBuilder:(context,index){
                final p = payments[index];
                return Card(
                  child: ListTile(
                    title: Text("₹${p['amount']} - ${p['method']}"),
                    subtitle: Text("${p['date']}"),
                  ),
                );
              },
            ),

            const SizedBox(height:20),

            sectionTitle("Case Notes"),

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
                  Text("Total Fee: ₹$totalFee"),
                  Text("Paid: ₹$totalPaid"),
                  Text(
                    "Remaining: ₹$remaining",
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                      builder: (context) => AddHearingScreen(caseId: data['id']),
                    ),
                  ).then((_) => loadHistory());
                }),

                actionCard(Icons.payment, "Add Payment", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPaymentScreen(caseId: data['id']),
                    ),
                  ).then((_) => loadHistory());
                }),

                actionCard(Icons.note_add, "Add Notes", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddNoteScreen(caseId: data['id']),
                    ),
                  ).then((_) => loadHistory());
                }),

                actionCard(Icons.edit, "Edit Case", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCaseScreen(caseItem: data),
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

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize:18,
          fontWeight: FontWeight.bold
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
            Icon(icon, size: 32, color: const Color(0xFFC9A227)),
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