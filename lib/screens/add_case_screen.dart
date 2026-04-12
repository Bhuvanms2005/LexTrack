import 'package:flutter/material.dart';
import '../database/case_database.dart';
class AddCaseScreen extends StatefulWidget{
  const AddCaseScreen({super.key});
  @override
  State<AddCaseScreen> createState()=> _AddCaseScreenState();
}
class _AddCaseScreenState extends State<AddCaseScreen>{
  final TextEditingController caseNumberController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController opponentController = TextEditingController();
  final TextEditingController courtController = TextEditingController();
  final TextEditingController caseTypeController = TextEditingController();
  final TextEditingController feeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime?hearingDate;
  Future<void> pickDate() async{
    DateTime? picked= await showDatePicker(
      context:context,
      initialDate:DateTime.now(),
      firstDate:DateTime(2000),
      lastDate:DateTime(2100),
    );
    if(picked!=null){
      setState((){
        hearingDate=picked;
      });
    }
  }
 void saveCase() async {
  try {

    if(caseNumberController.text.isEmpty || clientController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields"))
      );
      return;
    }

    Map<String,dynamic> caseData = {
      "caseNumber": caseNumberController.text,
      "year": yearController.text,
      "clientName": clientController.text,
      "opponentName": opponentController.text,
      "courtName": courtController.text,
      "caseType": caseTypeController.text,
      "hearingDate": hearingDate == null
          ? ""
          : "${hearingDate!.day}/${hearingDate!.month}/${hearingDate!.year}",
      "totalFee": feeController.text,
      "notes": notesController.text,
      "status": "Pending"
    };

    await CaseDatabase.insertCase(caseData);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Case added successfully")),
    );

    Navigator.pop(context,true);

  } catch (e) {
    print("ERROR: $e");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
  title: const Text("Add Case"),
  backgroundColor: const Color(0xFF162F4A),
  foregroundColor: Colors.white,
),
    backgroundColor:const Color(0xFF1E3A5F),
    body:Center(
      child:ConstrainedBox(
        constraints:const BoxConstraints(maxWidth:700),
        child:SingleChildScrollView(
          padding:const EdgeInsets.all(20),
          child:Container(
            padding:const EdgeInsets.all(20),
            decoration:BoxDecoration(
              color:Colors.white,
              borderRadius:BorderRadius.circular(16),
            ),
            child:Column(
              children:[
                Row(
                  children:[
                    Expanded(
                      child:TextField(
                        controller:caseNumberController,
                        keyboardType: TextInputType.number,
                        decoration:const InputDecoration(
                          labelText: "Case Number",
                          border:OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child:TextField(
                        controller:yearController,
                        keyboardType: TextInputType.number,
                        decoration:const InputDecoration(
                          labelText: "Year",
                          border:OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller:clientController,
                  decoration:const InputDecoration(
                    labelText: "Client Name",
                    border:OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller:opponentController,
                  decoration:const InputDecoration(
                    labelText: "Opponent Name",
                    border:OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller:courtController,
                  decoration:const InputDecoration(
                    labelText: "Court Name",
                    border:OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller:caseTypeController,
                  decoration:const InputDecoration(
                    labelText: "Case Type",
                    border:OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                 InkWell(
                    onTap: pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: double.infinity,
                      child: Text(
                        hearingDate == null
                            ? "Select First Hearing Date"
                            : "${hearingDate!.day}/${hearingDate!.month}/${hearingDate!.year}",
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField( 
                    controller:feeController,
                    keyboardType: TextInputType.number,
                    decoration:const InputDecoration(
                      labelText: "Total Fee",
                      border:OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller:notesController,
                    maxLines: 4,
                    decoration:const InputDecoration(
                      labelText: "Additional Notes",
                      border:OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width:double.infinity,
                    height:50,
                    child:ElevatedButton(
                      style:ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC9A227),
                      ),
                      onPressed: saveCase,
                      child:const Text(
                        "Save Case",
                        style:TextStyle(
                          fontSize:16
                        ),
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
}