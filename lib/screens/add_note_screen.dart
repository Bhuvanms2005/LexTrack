import 'package:flutter/material.dart';
import '../database/case_database.dart';
import '../widgets/app_drawer.dart';

class AddNoteScreen extends StatefulWidget {

  final int caseId;

  const AddNoteScreen({super.key, required this.caseId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {

  final TextEditingController noteController = TextEditingController();

  void saveNote() async {

    if(noteController.text.isEmpty){
      return;
    }

    Map<String,dynamic> data = {
      "caseId": widget.caseId,
      "note": noteController.text,
      "date": DateTime.now().toString()
    };

    await CaseDatabase.insertNote(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Note added successfully"))
    );

    Future.delayed(const Duration(seconds:1), (){
      Navigator.pop(context);
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

      drawer: const AppDrawer(),

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
            children: [

              TextField(
                controller: noteController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: "Case Note",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height:20),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A227),
                  ),

                  onPressed: saveNote,

                  child: const Text(
                    "Save Note",
                    style: TextStyle(fontSize:16),
                  ),

                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}