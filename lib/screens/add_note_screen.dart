import 'package:flutter/material.dart';
import '../database/case_database.dart';

class AddNoteScreen extends StatefulWidget {
  final int caseId;

  const AddNoteScreen({super.key, required this.caseId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final TextEditingController noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void saveNote() async {
    if (noteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please write a note before saving"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    Map<String, dynamic> data = {
      "caseId": widget.caseId,
      "note": noteController.text.trim(),
      "date": "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    };

    await CaseDatabase.insertNote(data);

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note saved successfully ✓")),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
        backgroundColor: const Color(0xFF162F4A),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF1E3A5F),
      body: Padding(
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
                "Case Note",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF162F4A)),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextField(
                  controller: noteController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: "Write your case note here...",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A227),
                  ),
                  onPressed: _isSaving ? null : saveNote,
                  child: _isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),
                        )
                      : const Text("Save Note", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}