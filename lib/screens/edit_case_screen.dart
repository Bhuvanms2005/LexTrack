import 'package:flutter/material.dart';
import '../database/case_database.dart';

class EditCaseScreen extends StatefulWidget {
  final Map<String, dynamic> caseItem;

  const EditCaseScreen({super.key, required this.caseItem});

  @override
  State<EditCaseScreen> createState() => _EditCaseScreenState();
}

class _EditCaseScreenState extends State<EditCaseScreen> {
  late TextEditingController clientController;
  late TextEditingController opponentController;
  late TextEditingController courtController;
  late TextEditingController caseTypeController;
  late TextEditingController feeController;
  late TextEditingController notesController;

  DateTime? hearingDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    clientController =
        TextEditingController(text: widget.caseItem['clientName']);
    opponentController =
        TextEditingController(text: widget.caseItem['opponentName']);
    courtController =
        TextEditingController(text: widget.caseItem['courtName']);
    caseTypeController =
        TextEditingController(text: widget.caseItem['caseType']);
    feeController =
        TextEditingController(text: widget.caseItem['totalFee']);
    notesController =
        TextEditingController(text: widget.caseItem['notes']);

    // Try to parse existing hearing date
    final existingDate = widget.caseItem['hearingDate'];
    if (existingDate != null && existingDate.toString().isNotEmpty) {
      try {
        final parts = existingDate.toString().split('/');
        if (parts.length == 3) {
          hearingDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
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
      initialDate: hearingDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => hearingDate = picked);
    }
  }

  String formatDisplayDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void updateCase() async {
    if (clientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Client name is required"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    Map<String, dynamic> data = {
      "clientName": clientController.text.trim(),
      "opponentName": opponentController.text.trim(),
      "courtName": courtController.text.trim(),
      "caseType": caseTypeController.text.trim(),
      "totalFee": feeController.text.trim(),
      "notes": notesController.text.trim(),
      if (hearingDate != null) "hearingDate": formatDisplayDate(hearingDate!),
    };

    await CaseDatabase.updateCase(widget.caseItem['id'], data);

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Case updated successfully ✓")),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Case"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Editing: ${widget.caseItem['caseNumber']}/${widget.caseItem['year']}",
                  style: const TextStyle(
                    color: Color(0xFF162F4A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),

                _field(controller: clientController, label: "Client Name *"),
                const SizedBox(height: 15),

                _field(controller: opponentController, label: "Opponent Name"),
                const SizedBox(height: 15),

                _field(controller: courtController, label: "Court Name"),
                const SizedBox(height: 15),

                _field(controller: caseTypeController, label: "Case Type"),
                const SizedBox(height: 15),

                // Hearing date picker
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
                        const Icon(Icons.event, size: 18, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          hearingDate == null
                              ? "Select Next Hearing Date"
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
                ),
                const SizedBox(height: 15),

                _field(
                  controller: notesController,
                  label: "Notes",
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A227),
                    ),
                    onPressed: _isSaving ? null : updateCase,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          )
                        : const Text(
                            "Update Case",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}