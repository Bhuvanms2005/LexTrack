import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateCaseReport(
    Map<String, dynamic> caseData,
    List<Map<String, dynamic>> hearings,
    List<Map<String, dynamic>> payments,
    List<Map<String, dynamic>> notes,
    int totalPaid,
  ) async {
    final pdf = pw.Document();

    final int totalFee =
        int.tryParse(caseData['totalFee'].toString()) ?? 0;
    final int remaining = totalFee - totalPaid;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "LexTrack Case Report",
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Case Details",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(),
          _buildRow("Case Number",
              "${caseData['caseNumber']}/${caseData['year']}"),
          _buildRow("Client Name", caseData['clientName']),
          _buildRow("Opponent Name", caseData['opponentName']),
          _buildRow("Court Name", caseData['courtName']),
          _buildRow("Case Type", caseData['caseType']),
          _buildRow("Hearing Date", caseData['hearingDate']),
          _buildRow("Status", caseData['status']),
          pw.SizedBox(height: 20),
          pw.Text(
            "Financial Summary",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(),
          _buildRow("Total Fee", "₹$totalFee"),
          _buildRow("Paid Amount", "₹$totalPaid"),
          _buildRow("Remaining Amount", "₹$remaining"),
          pw.SizedBox(height: 20),
          pw.Text(
            "Hearing History",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(),
          ...hearings.map(
            (h) => pw.Text(
              "${h['date']} - ${h['stage']} (Next: ${h['nextHearing']})",
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Payment History",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(),
          ...payments.map(
            (p) => pw.Text(
              "₹${p['amount']} - ${p['method']} (${p['date']})",
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Case Notes",
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Divider(),
          ...notes.map(
            (n) => pw.Text("${n['date']} - ${n['note']}"),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildRow(String title, dynamic value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              title,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(value?.toString() ?? ""),
          ),
        ],
      ),
    );
  }
}