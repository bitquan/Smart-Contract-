import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/contract_model.dart';

class PDFService {
  static Future<Uint8List> generateServiceAgreementPDF(ContractModel contract) async {
    final pdf = pw.Document();
    final formData = contract.formData;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'SERVICE AGREEMENT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Parties
              pw.Text(
                'PARTIES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'This Service Agreement ("Agreement") is entered into on ${_formatDate(contract.createdAt)} by and between:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Service Provider: ${formData['providerName'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Address: ${formData['providerAddress'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Client: ${formData['clientName'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Address: ${formData['clientAddress'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Services
              pw.Text(
                'SERVICES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'The Service Provider agrees to provide the following services:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                formData['serviceDescription'] ?? 'N/A',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Payment Terms
              pw.Text(
                'PAYMENT TERMS',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total Amount: \$${formData['serviceAmount'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Payment Terms: ${formData['paymentTerms'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Timeline
              pw.Text(
                'TIMELINE',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Start Date: ${formData['startDate'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              if (formData['endDate'] != null && formData['endDate'].toString().isNotEmpty)
                pw.Text(
                  'End Date: ${formData['endDate']}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              pw.SizedBox(height: 20),
              
              // Governing Law
              pw.Text(
                'GOVERNING LAW',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'This Agreement shall be governed by the laws of ${formData['jurisdiction'] ?? 'N/A'}.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),
              
              // Signatures
              pw.Text(
                'SIGNATURES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Service Provider:', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        height: 1,
                        width: 200,
                        color: PdfColors.black,
                      ),
                      pw.Text('${formData['providerName'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Date: ___________', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Client:', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        height: 1,
                        width: 200,
                        color: PdfColors.black,
                      ),
                      pw.Text('${formData['clientName'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Date: ___________', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateNDAPDF(ContractModel contract) async {
    final pdf = pw.Document();
    final formData = contract.formData;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'NON-DISCLOSURE AGREEMENT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              
              // Parties
              pw.Text(
                'This Non-Disclosure Agreement ("Agreement") is entered into on ${_formatDate(contract.createdAt)} by and between:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Disclosing Party: ${formData['disclosingParty'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Receiving Party: ${formData['receivingParty'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Purpose
              pw.Text(
                'PURPOSE',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Purpose of disclosure: ${formData['purposeOfDisclosure'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Terms
              pw.Text(
                'CONFIDENTIAL INFORMATION',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'The Receiving Party agrees to maintain the confidentiality of all information disclosed by the Disclosing Party and not to disclose such information to any third parties without prior written consent.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Duration
              pw.Text(
                'DURATION',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'This Agreement shall remain in effect for: ${formData['duration'] ?? 'N/A'}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              
              // Governing Law
              pw.Text(
                'GOVERNING LAW',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'This Agreement shall be governed by the laws of ${formData['jurisdiction'] ?? 'N/A'}.',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 30),
              
              // Signatures
              pw.Text(
                'SIGNATURES',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Disclosing Party:', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        height: 1,
                        width: 200,
                        color: PdfColors.black,
                      ),
                      pw.Text('${formData['disclosingParty'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Date: ___________', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Receiving Party:', style: const pw.TextStyle(fontSize: 12)),
                      pw.SizedBox(height: 30),
                      pw.Container(
                        height: 1,
                        width: 200,
                        color: PdfColors.black,
                      ),
                      pw.Text('${formData['receivingParty'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Date: ___________', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateContractPDF(ContractModel contract) async {
    switch (contract.type) {
      case ContractType.serviceAgreement:
        return generateServiceAgreementPDF(contract);
      case ContractType.nda:
        return generateNDAPDF(contract);
      case ContractType.paymentTerms:
        return generatePaymentTermsPDF(contract);
      case ContractType.contractorAgreement:
        return generateContractorAgreementPDF(contract);
      default:
        return generateGenericContractPDF(contract);
    }
  }

  static Future<Uint8List> generatePaymentTermsPDF(ContractModel contract) async {
    final pdf = pw.Document();
    final formData = contract.formData;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'PAYMENT TERMS AGREEMENT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'This Payment Terms Agreement is entered into on ${_formatDate(contract.createdAt)} between:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Payer: ${formData['payerName'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Payee: ${formData['payeeName'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Text('Total Amount: \$${formData['totalAmount'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Payment Schedule: ${formData['paymentSchedule'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Due Date: ${formData['dueDate'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              if (formData['lateFee'] != null)
                pw.Text('Late Fee: ${formData['lateFee']}', style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateContractorAgreementPDF(ContractModel contract) async {
    final pdf = pw.Document();
    final formData = contract.formData;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'INDEPENDENT CONTRACTOR AGREEMENT',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'This Independent Contractor Agreement is entered into on ${_formatDate(contract.createdAt)} between:',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Contractor: ${formData['contractorName'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Company: ${formData['companyName'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Text('Work Description: ${formData['workDescription'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Compensation: \$${formData['compensationAmount'] ?? 'N/A'} (${formData['compensationType'] ?? 'N/A'})', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Work Location: ${formData['workLocation'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('Start Date: ${formData['startDate'] ?? 'N/A'}', style: const pw.TextStyle(fontSize: 12)),
              if (formData['endDate'] != null)
                pw.Text('End Date: ${formData['endDate']}', style: const pw.TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateGenericContractPDF(ContractModel contract) async {
    final pdf = pw.Document();
    final formData = contract.formData;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  contract.typeDisplayName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'Contract created on ${_formatDate(contract.createdAt)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              ...formData.entries.map((entry) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Text(
                  '${entry.key}: ${entry.value}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              )),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}