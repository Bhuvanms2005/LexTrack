import 'package:flutter/material.dart';
import '../database/case_database.dart';
import '../widgets/app_drawer.dart';
class AddHearingScreen extends StatefulWidget {

  final int caseId;

  const AddHearingScreen({super.key, required this.caseId});

  @override
  State<AddHearingScreen> createState() => _AddHearingScreenState();
}

class _AddHearingScreenState extends State<AddHearingScreen> {

  final TextEditingController notesController = TextEditingController();

  DateTime hearingDate = DateTime.now();
  DateTime nextHearingDate = DateTime.now();

  String stage = "Filing";

  List<String> stages = [
    "Filing",
    "Notice",
    "Evidence",
    "Cross Examination",
    "Arguments",
    "Judgement",
    "Adjourned"
  ];

  Future<void> pickHearingDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: hearingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if(picked != null){
      setState(() {
        hearingDate = picked;
      });
    }
  }

  Future<void> pickNextDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: nextHearingDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if(picked != null){
      setState(() {
        nextHearingDate = picked;
      });
    }
  }

  void saveHearing() async {

  String hearing = "${hearingDate.day}/${hearingDate.month}/${hearingDate.year}";
  String next = "${nextHearingDate.day}/${nextHearingDate.month}/${nextHearingDate.year}";

  Map<String,dynamic> hearingData = {
    "caseId": widget.caseId,
    "date": hearing,
    "stage": stage,
    "notes": notesController.text,
    "nextHearing": next
  };

  try {

    await CaseDatabase.insertHearing(hearingData);

    await CaseDatabase.updateNextHearing(widget.caseId, next);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hearing added successfully"))
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);
    });

  } catch(e) {

    print("Hearing insert error: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Database error while saving hearing"))
    );

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

              DropdownButtonFormField(

                value: stage,

                items: stages.map((s){
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  );
                }).toList(),

                onChanged: (value){
                  setState(() {
                    stage = value!;
                  });
                },

                decoration: const InputDecoration(
                  labelText: "Stage",
                  border: OutlineInputBorder(),
                ),

              ),

              const SizedBox(height: 15),

              InkWell(
                onTap: pickHearingDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  width: double.infinity,
                  child: Text(
                    "Hearing Date: ${hearingDate.day}/${hearingDate.month}/${hearingDate.year}",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              InkWell(
                onTap: pickNextDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  width: double.infinity,
                  child: Text(
                    "Next Hearing: ${nextHearingDate.day}/${nextHearingDate.month}/${nextHearingDate.year}",
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
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

                  onPressed: saveHearing,

                  child: const Text(
                    "Save Hearing",
                    style: TextStyle(fontSize: 16),
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