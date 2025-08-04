import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';
import '../../models/contract_model.dart';
import '../../services/firebase_service.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final _firebaseService = FirebaseService();
  ContractModel? _contract;
  bool _isLoading = true;
  bool _isSaving = false;

  late SignatureController _clientSignatureController;
  late SignatureController _providerSignatureController;

  String? _clientSignatureData;
  String? _providerSignatureData;

  @override
  void initState() {
    super.initState();
    _clientSignatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _providerSignatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    _loadContract();
  }

  @override
  void dispose() {
    _clientSignatureController.dispose();
    _providerSignatureController.dispose();
    super.dispose();
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

  Future<void> _saveSignatures() async {
    if (_contract == null) return;

    // Check if at least one signature is provided
    final clientEmpty = _clientSignatureController.isEmpty;
    final providerEmpty = _providerSignatureController.isEmpty;

    if (clientEmpty && providerEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide at least one signature'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? clientSignature;
      String? providerSignature;

      // Get client signature if not empty
      if (!clientEmpty) {
        final clientBytes = await _clientSignatureController.toPngBytes();
        if (clientBytes != null) {
          // Convert to base64 string for storage
          clientSignature = 'data:image/png;base64,${_bytesToBase64(clientBytes)}';
        }
      }

      // Get provider signature if not empty
      if (!providerEmpty) {
        final providerBytes = await _providerSignatureController.toPngBytes();
        if (providerBytes != null) {
          providerSignature = 'data:image/png;base64,${_bytesToBase64(providerBytes)}';
        }
      }

      // Update contract with signatures
      final updatedContract = _contract!.copyWith(
        clientSignature: clientSignature ?? _contract!.clientSignature,
        providerSignature: providerSignature ?? _contract!.providerSignature,
        status: ContractStatus.signed,
        signedAt: DateTime.now(),
      );

      await _firebaseService.updateContract(updatedContract);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signatures saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving signatures: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _bytesToBase64(Uint8List bytes) {
    // Convert bytes to base64 string
    return bytes.map((byte) => String.fromCharCode(byte)).join();
  }

  void _clearClientSignature() {
    _clientSignatureController.clear();
  }

  void _clearProviderSignature() {
    _providerSignatureController.clear();
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
        title: const Text('Digital Signatures'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/contract-preview?id=${_contract!.id}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contract Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Between: ${_getPartyNames()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Client Signature Section
              _buildSignatureSection(
                title: 'Client Signature',
                subtitle: _contract!.clientName ?? 'Client',
                controller: _clientSignatureController,
                onClear: _clearClientSignature,
              ),
              const SizedBox(height: 32),

              // Provider Signature Section
              _buildSignatureSection(
                title: 'Service Provider Signature',
                subtitle: _contract!.providerName ?? 'Provider',
                controller: _providerSignatureController,
                onClear: _clearProviderSignature,
              ),
              const SizedBox(height: 32),

              // Legal Notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Legal Notice',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'By signing this contract electronically, both parties agree that the digital signatures are legally binding and have the same force and effect as handwritten signatures. The timestamp and IP address are recorded for legal validity.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSignatures,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Save Signatures & Complete Contract',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureSection({
    required String title,
    required String subtitle,
    required SignatureController controller,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        
        // Signature Canvas
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Signature(
              controller: controller,
              backgroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Clear Button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ),
        
        // Instructions
        Text(
          'Sign above using your mouse, trackpad, or touch screen',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _getPartyNames() {
    final client = _contract!.clientName ?? 
                   _contract!.formData['clientName'] ?? 
                   _contract!.formData['receivingParty'] ?? 
                   _contract!.formData['payerName'] ?? 
                   'Client';
    
    final provider = _contract!.providerName ?? 
                     _contract!.formData['providerName'] ?? 
                     _contract!.formData['disclosingParty'] ?? 
                     _contract!.formData['payeeName'] ?? 
                     'Provider';
    
    return '$client and $provider';
  }
}