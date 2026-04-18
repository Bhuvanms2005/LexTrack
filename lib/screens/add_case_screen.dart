import 'package:flutter/material.dart';
import '../database/case_database.dart';

class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});

  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final TextEditingController caseNumberController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController opponentController = TextEditingController();
  final TextEditingController courtController = TextEditingController();
  final TextEditingController caseTypeController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime? hearingDate;
  bool _isSaving = false;

  @override
  void dispose() {
    caseNumberController.dispose();
    yearController.dispose();
    clientController.dispose();
    opponentController.dispose();
    courtController.dispose();
    caseTypeController.dispose();
    feeController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        hearingDate = picked;
      });
    }
  }

  String formatDisplayDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void saveCase() async {
    // Validate required fields
    if (caseNumberController.text.trim().isEmpty) {
      _showError("Case number is required");
      return;
    }
    if (yearController.text.trim().isEmpty) {
      _showError("Year is required");
      return;
    }
    if (clientController.text.trim().isEmpty) {
      _showError("Client name is required");
      return;
    }

    setState(() => _isSaving = true);

    try {
      Map<String, dynamic> caseData = {
        "caseNumber": caseNumberController.text.trim(),
        "year": yearController.text.trim(),
        "clientName": clientController.text.trim(),
        "opponentName": opponentController.text.trim(),
        "courtName": courtController.text.trim(),
        "caseType": caseTypeController.text.trim(),
        "hearingDate": hearingDate == null
            ? ""
            : formatDisplayDate(hearingDate!),
        "totalFee": feeController.text.trim(),
        "notes": notesController.text.trim(),
        "status": "Pending",
      };

      await CaseDatabase.insertCase(caseData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Case added successfully ✓")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showError("Error saving case: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Case"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Case Information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF162F4A),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Case Number & Year
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _field(
                          controller: caseNumberController,
                          label: "Case Number *",
                          keyboard: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          controller: yearController,
                          label: "Year *",
                          keyboard: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  _field(
                    controller: clientController,
                    label: "Client Name *",
                    prefix: Icons.person,
                  ),
                  const SizedBox(height: 15),

                  _field(
                    controller: opponentController,
                    label: "Opponent Name",
                    prefix: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),

                  _field(
                    controller: courtController,
                    label: "Court Name",
                    prefix: Icons.account_balance,
                  ),
                  const SizedBox(height: 15),

                  _field(
                    controller: caseTypeController,
                    label: "Case Type",
                    prefix: Icons.gavel,
                  ),
                  const SizedBox(height: 15),

                  // Date picker
                  InkWell(
                    onTap: pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 10),
                          Text(
                            hearingDate == null
                                ? "Select First Hearing Date"
                                : formatDisplayDate(hearingDate!),
                            style: TextStyle(
                              color: hearingDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _field(
                    controller: feeController,
                    label: "Total Fee (₹)",
                    keyboard: TextInputType.number,
                    prefix: Icons.currency_rupee,
                  ),
                  const SizedBox(height: 15),

                  _field(
                    controller: notesController,
                    label: "Additional Notes",
                    maxLines: 4,
                    prefix: Icons.notes,
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A227),
                      ),
                      onPressed: _isSaving ? null : saveCase,
                      child: _isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3),
                            )
                          : const Text(
                              "Save Case",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    IconData? prefix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: prefix != null ? Icon(prefix, color: Colors.grey) : null,
      ),
    );
  }
}