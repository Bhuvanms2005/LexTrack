import 'package:flutter/material.dart';
import '../database/case_database.dart';
import '../services/pdf_service.dart';
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
  List<Map<String, dynamic>> hearings = [];
  List<Map<String, dynamic>> payments = [];
  List<Map<String, dynamic>> notes = [];

  int totalPaid = 0;
  Map<String, dynamic>? caseData;

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
          content: const Text(
              "Are you sure you want to delete this case and all its data? This cannot be undone."),
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = caseData ?? widget.caseItem;

    int totalFee = int.tryParse(data['totalFee'].toString()) ?? 0;
    int remaining = totalFee - totalPaid;
    double progress = totalFee > 0 ? (totalPaid / totalFee).clamp(0.0, 1.0) : 0.0;

    String status = data['status'] ?? "Pending";
    bool isCompleted = status == "Completed";

    return Scaffold(
      appBar: AppBar(
        title: Text("${data['caseNumber']}/${data['year']}"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Delete Case",
            onPressed: confirmDelete,
          )
        ],
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Case Info Card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${data['caseNumber']}/${data['year']}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isCompleted ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  detailRow(Icons.person, "Client", data['clientName']),
                  detailRow(Icons.person_outline, "Opponent", data['opponentName']),
                  detailRow(Icons.account_balance, "Court", data['courtName']),
                  detailRow(Icons.gavel, "Case Type", data['caseType']),
                  detailRow(Icons.event, "Next Hearing", data['hearingDate']),
                  if (data['notes'] != null &&
                      data['notes'].toString().isNotEmpty) ...[
                    const Divider(height: 20),
                    const Text(
                      "Case Notes",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${data['notes']}",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: isCompleted
                              ? null
                              : () => updateStatus("Completed"),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text("Mark Done"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed:
                              !isCompleted ? null : () => updateStatus("Pending"),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("Reopen"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Financial Summary Card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Financial Summary",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _feeStat("Total Fee", "₹$totalFee", Colors.black87),
                      _feeStat("Paid", "₹$totalPaid", Colors.green.shade700),
                      _feeStat(
                        "Remaining",
                        "₹$remaining",
                        remaining > 0 ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.red.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.green.shade600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}% of fee collected",
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
              children: [
                actionCard(Icons.event_note, "Add\nHearing", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddHearingScreen(caseId: data['id']),
                    ),
                  ).then((_) => loadHistory());
                }),
                actionCard(Icons.payment, "Add\nPayment", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPaymentScreen(caseId: data['id']),
                    ),
                  ).then((_) => loadHistory());
                }),
                actionCard(Icons.note_add, "Add\nNote", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddNoteScreen(caseId: data['id']),
                    ),
                  ).then((_) => loadHistory());
                }),
                actionCard(Icons.edit, "Edit\nCase", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCaseScreen(caseItem: data),
                    ),
                  ).then((_) => loadHistory());
                }),
                actionCard(Icons.picture_as_pdf, "Export\nPDF", () {
                  PdfService.generateCaseReport(
                      data, hearings, payments, notes, totalPaid);
                }),
              ],
            ),

            const SizedBox(height: 20),

            // Hearing History
            sectionTitle("Hearing History", Icons.history),
            hearings.isEmpty
                ? _emptyHint("No hearings recorded yet")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hearings.length,
                    itemBuilder: (context, index) {
                      final h = hearings[index];
                      return _listCard(
                        title: "${h['date']} — ${h['stage']}",
                        subtitle: "Next hearing: ${h['nextHearing']}",
                        icon: Icons.gavel,
                        iconColor: const Color(0xFF1565C0),
                      );
                    },
                  ),

            const SizedBox(height: 20),

            // Payment History
            sectionTitle("Payment History", Icons.receipt_long),
            payments.isEmpty
                ? _emptyHint("No payments recorded yet")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final p = payments[index];
                      return _listCard(
                        title: "₹${p['amount']} — ${p['method']}",
                        subtitle: p['date'],
                        icon: Icons.currency_rupee,
                        iconColor: Colors.green.shade700,
                      );
                    },
                  ),

            const SizedBox(height: 20),

            // Case Notes
            sectionTitle("Case Notes", Icons.sticky_note_2_outlined),
            notes.isEmpty
                ? _emptyHint("No notes added yet")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final n = notes[index];
                      return _listCard(
                        title: n['note'],
                        subtitle: n['date'],
                        icon: Icons.notes,
                        iconColor: const Color(0xFFC9A227),
                      );
                    },
                  ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC9A227), size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget detailRow(IconData icon, String label, dynamic value) {
    if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              "$value",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _feeStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(label,
            style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }

  Widget _listCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(color: Colors.white54, fontSize: 13)),
      ),
    );
  }

  Widget actionCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: const Color(0xFFC9A227)),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}