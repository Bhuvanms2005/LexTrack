import 'package:flutter/material.dart';
import '../database/case_database.dart';

class AddHearingScreen extends StatefulWidget {
  final int caseId;

  const AddHearingScreen({super.key, required this.caseId});

  @override
  State<AddHearingScreen> createState() => _AddHearingScreenState();
}

class _AddHearingScreenState extends State<AddHearingScreen> {
  final TextEditingController notesController = TextEditingController();

  DateTime hearingDate = DateTime.now();
  DateTime nextHearingDate = DateTime.now().add(const Duration(days: 30));

  String stage = "Filing";
  bool _isSaving = false;

  final List<String> stages = [
    "Filing",
    "Notice",
    "Evidence",
    "Cross Examination",
    "Arguments",
    "Judgement",
    "Adjourned",
  ];

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickHearingDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: hearingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => hearingDate = picked);
  }

  Future<void> pickNextDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: nextHearingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => nextHearingDate = picked);
  }

  String fmt(DateTime d) => "${d.day}/${d.month}/${d.year}";

  void saveHearing() async {
    setState(() => _isSaving = true);

    Map<String, dynamic> hearingData = {
      "caseId": widget.caseId,
      "date": fmt(hearingDate),
      "stage": stage,
      "notes": notesController.text.trim(),
      "nextHearing": fmt(nextHearingDate),
    };

    try {
      await CaseDatabase.insertHearing(hearingData);
      await CaseDatabase.updateNextHearing(widget.caseId, fmt(nextHearingDate));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hearing added successfully ✓")),
      );

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Error saving hearing: $e"),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Hearing"),
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
                DropdownButtonFormField<String>(
                  value: stage,
                  items: stages
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => stage = value!),
                  decoration: InputDecoration(
                    labelText: "Hearing Stage",
                    prefixIcon: const Icon(Icons.gavel),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 15),

                _dateTile(
                  label: "Hearing Date",
                  date: hearingDate,
                  onTap: pickHearingDate,
                ),

                const SizedBox(height: 15),

                _dateTile(
                  label: "Next Hearing Date",
                  date: nextHearingDate,
                  onTap: pickNextDate,
                  accent: const Color(0xFF1565C0),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Hearing Notes",
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A227),
                    ),
                    onPressed: _isSaving ? null : saveHearing,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          )
                        : const Text("Save Hearing",
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    Color accent = const Color(0xFFC9A227),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: accent),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black45)),
                Text(
                  "${date.day}/${date.month}/${date.year}",
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}