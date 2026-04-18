import 'package:flutter/material.dart';
import '../database/case_database.dart';

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
  bool _isSaving = false;

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => paymentDate = picked);
  }

  void savePayment() async {
    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter payment amount"),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (int.tryParse(amountController.text.trim()) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please enter a valid amount"),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    Map<String, dynamic> paymentData = {
      "caseId": widget.caseId,
      "amount": amountController.text.trim(),
      "date":
          "${paymentDate.day}/${paymentDate.month}/${paymentDate.year}",
      "method": paymentMethod,
      "notes": notesController.text.trim(),
    };

    await CaseDatabase.insertPayment(paymentData);

    if (!mounted) return;

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment recorded successfully ✓")),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Payment"),
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
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Payment Amount (₹) *",
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: InputDecoration(
                    labelText: "Payment Method",
                    prefixIcon: const Icon(Icons.payment),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Cash", child: Text("Cash")),
                    DropdownMenuItem(value: "UPI", child: Text("UPI")),
                    DropdownMenuItem(
                        value: "Bank Transfer", child: Text("Bank Transfer")),
                    DropdownMenuItem(
                        value: "Cheque", child: Text("Cheque")),
                  ],
                  onChanged: (value) =>
                      setState(() => paymentMethod = value!),
                ),

                const SizedBox(height: 15),

                InkWell(
                  onTap: pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: Colors.grey),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Payment Date",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black45)),
                            Text(
                              "${paymentDate.day}/${paymentDate.month}/${paymentDate.year}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Notes (optional)",
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
                    onPressed: _isSaving ? null : savePayment,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          )
                        : const Text("Save Payment",
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
}