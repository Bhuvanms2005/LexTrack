import 'package:flutter/material.dart';
import '../database/case_database.dart';
import '../widgets/app_drawer.dart';
class AddPaymentScreen extends StatefulWidget {

  final int caseId;

  const AddPaymentScreen({super.key, required this.caseId});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {

  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String paymentMethod = "Cash";
  DateTime paymentDate = DateTime.now();

 void savePayment() async {

  Map<String,dynamic> paymentData = {
    "caseId": widget.caseId,
    "amount": amountController.text,
    "date": "${paymentDate.day}/${paymentDate.month}/${paymentDate.year}",
    "method": paymentMethod,
    "notes": notesController.text
  };

  await CaseDatabase.insertPayment(paymentData);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Payment added successfully"))
  );

  Future.delayed(const Duration(seconds: 1), () {
    Navigator.pop(context);
  });

}

  Future<void> pickDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if(picked != null){
      setState(() {
        paymentDate = picked;
      });
    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add Payment"),
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
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Payment Amount",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(

                value: paymentMethod,

                decoration: const InputDecoration(
                  labelText: "Payment Method",
                  border: OutlineInputBorder(),
                ),

                items: const [

                  DropdownMenuItem(
                    value: "Cash",
                    child: Text("Cash"),
                  ),

                  DropdownMenuItem(
                    value: "UPI",
                    child: Text("UPI"),
                  ),

                  DropdownMenuItem(
                    value: "Bank Transfer",
                    child: Text("Bank Transfer"),
                  ),

                ],

                onChanged: (value){
                  setState(() {
                    paymentMethod = value!;
                  });
                },

              ),

              const SizedBox(height: 15),

              InkWell(
                onTap: pickDate,
                child: Container(

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),

                  width: double.infinity,

                  child: Text(
                    "${paymentDate.day}/${paymentDate.month}/${paymentDate.year}",
                  ),

                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: notesController,
                maxLines: 3,
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

                  onPressed: savePayment,

                  child: const Text(
                    "Save Payment",
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