import 'package:flutter/material.dart';
import '../database/case_database.dart';
import '../widgets/app_drawer.dart';

class EditCaseScreen extends StatefulWidget {

  final Map<String,dynamic> caseItem;

  const EditCaseScreen({super.key, required this.caseItem});

  @override
  State<EditCaseScreen> createState() => _EditCaseScreenState();
}

class _EditCaseScreenState extends State<EditCaseScreen> {

  late TextEditingController clientController;
  late TextEditingController opponentController;
  late TextEditingController courtController;
  late TextEditingController feeController;
  late TextEditingController notesController;

  @override
  void initState() {

    super.initState();

    clientController =
        TextEditingController(text: widget.caseItem['clientName']);

    opponentController =
        TextEditingController(text: widget.caseItem['opponentName']);

    courtController =
        TextEditingController(text: widget.caseItem['courtName']);

    feeController =
        TextEditingController(text: widget.caseItem['totalFee']);

    notesController =
        TextEditingController(text: widget.caseItem['notes']);
  }

  void updateCase() async {

    Map<String,dynamic> data = {

      "clientName": clientController.text,
      "opponentName": opponentController.text,
      "courtName": courtController.text,
      "totalFee": feeController.text,
      "notes": notesController.text

    };

    await CaseDatabase.updateCase(widget.caseItem['id'], data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Case updated successfully"))
    );

    Future.delayed(const Duration(seconds:1), (){
      Navigator.pop(context);
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

      drawer: const AppDrawer(),

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
              children: [

                TextField(
                  controller: clientController,
                  decoration: const InputDecoration(
                    labelText: "Client Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height:15),

                TextField(
                  controller: opponentController,
                  decoration: const InputDecoration(
                    labelText: "Opponent Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height:15),

                TextField(
                  controller: courtController,
                  decoration: const InputDecoration(
                    labelText: "Court Name",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height:15),

                TextField(
                  controller: feeController,
                  decoration: const InputDecoration(
                    labelText: "Total Fee",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height:15),

                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Notes",
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

                    onPressed: updateCase,

                    child: const Text(
                      "Update Case",
                      style: TextStyle(fontSize:16),
                    ),

                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}