import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../models/contract_model.dart';
import '../../services/firebase_service.dart';
import '../../services/pdf_service.dart';

class ContractPreviewScreen extends StatefulWidget {
  const ContractPreviewScreen({super.key});

  @override
  State<ContractPreviewScreen> createState() => _ContractPreviewScreenState();
}

class _ContractPreviewScreenState extends State<ContractPreviewScreen> {
  final _firebaseService = FirebaseService();
  ContractModel? _contract;
  bool _isLoading = true;
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  void _loadContract() async {
    final uri = GoRouterState.of(context).uri;
    final contractId = uri.queryParameters['id'];
    
    if (contractId == null) {
      context.go('/dashboard');
      return;
    }

    try {
      final contract = await _firebaseService.getContract(contractId);
      if (contract != null && mounted) {
        setState(() {
          _contract = contract;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contract: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateAndDownloadPDF() async {
    if (_contract == null) return;

    setState(() => _isGeneratingPDF = true);

    try {
      final pdfBytes = await PDFService.generateContractPDF(_contract!);
      
      // Save to Firebase Storage
      final fileName = '${_contract!.typeDisplayName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      final downloadUrl = await _firebaseService.uploadPdfFile(
        fileName: fileName,
        fileBytes: pdfBytes,
        userId: _contract!.userId,
      );

      // Update contract with PDF URL
      final updatedContract = _contract!.copyWith(
        pdfUrl: downloadUrl,
        status: ContractStatus.awaitingSignature,
      );
      await _firebaseService.updateContract(updatedContract);

      // Download the PDF
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: '$fileName.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contract PDF generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPDF = false);
      }
    }
  }

  void _goToSignature() {
    if (_contract != null) {
      context.go('/signature?id=${_contract!.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_contract == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Contract Not Found')),
        body: const Center(
          child: Text('Contract not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Contract Preview'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingPDF ? null : _generateAndDownloadPDF,
            tooltip: 'Generate PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contract Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contract!.typeDisplayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created on ${_formatDate(_contract!.createdAt)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Status: ${_getStatusText(_contract!.status)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getStatusColor(_contract!.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contract Details
              const Text(
                'Contract Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _contract!.formData.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 200,
                              child: Text(
                                _formatFieldName(entry.key),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatFieldValue(entry.value),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPDF ? null : _generateAndDownloadPDF,
                      icon: _isGeneratingPDF 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label: Text(_isGeneratingPDF ? 'Generating PDF...' : 'Download PDF'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _goToSignature,
                      icon: const Icon(Icons.edit),
                      label: const Text('Add Signatures'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.green.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Next Steps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Review all contract details above\n'
                      '2. Generate and download the PDF\n'
                      '3. Add digital signatures from both parties\n'
                      '4. Both parties will receive a copy via email',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String _getStatusText(ContractStatus status) {
    switch (status) {
      case ContractStatus.draft:
        return 'Draft';
      case ContractStatus.awaitingSignature:
        return 'Awaiting Signature';
      case ContractStatus.signed:
        return 'Signed';
      case ContractStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor(ContractStatus status) {
    switch (status) {
      case ContractStatus.draft:
        return Colors.orange;
      case ContractStatus.awaitingSignature:
        return Colors.blue;
      case ContractStatus.signed:
        return Colors.green;
      case ContractStatus.completed:
        return Colors.grey;
    }
  }

  String _formatFieldName(String key) {
    // Convert camelCase to readable format
    String result = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    
    // Capitalize first letter
    result = result[0].toUpperCase() + result.substring(1);
    
    // Handle specific cases
    result = result.replaceAll('N D A', 'NDA');
    result = result.replaceAll('I P', 'IP');
    
    return result;
  }

  String _formatFieldValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }
}