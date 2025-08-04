import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/contract_model.dart';
import '../../utils/contract_templates.dart';
import '../../utils/validators.dart';
import '../../services/firebase_service.dart';

class ContractFormScreen extends StatefulWidget {
  final String contractType;

  const ContractFormScreen({
    super.key,
    required this.contractType,
  });

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formData = {};
  late Map<String, dynamic> _template;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _loadTemplate() {
    final contractType = ContractType.values.firstWhere(
      (type) => type.name == widget.contractType,
      orElse: () => ContractType.serviceAgreement,
    );
    
    _template = ContractTemplates.getTemplateByType(contractType);
    
    // Initialize controllers for text fields
    for (final field in _template['fields']) {
      if (field['type'] == 'text' || 
          field['type'] == 'textarea' || 
          field['type'] == 'number' ||
          field['type'] == 'date') {
        _controllers[field['key']] = TextEditingController();
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user can create contracts
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) {
      context.go('/login');
      return;
    }

    final canCreate = await _firebaseService.canUserCreateContract(currentUser.uid);
    if (!canCreate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to upgrade to create more contracts'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/subscription');
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Collect form data
      for (final field in _template['fields']) {
        final key = field['key'];
        if (_controllers.containsKey(key)) {
          _formData[key] = _controllers[key]!.text;
        }
      }

      // Create contract
      final contractType = ContractType.values.firstWhere(
        (type) => type.name == widget.contractType,
      );

      final contract = ContractModel(
        id: '', // Will be set by Firestore
        userId: currentUser.uid,
        type: contractType,
        status: ContractStatus.draft,
        formData: _formData,
        createdAt: DateTime.now(),
        clientName: _formData['clientName'] ?? _formData['receivingParty'] ?? _formData['payerName'],
        providerName: _formData['providerName'] ?? _formData['disclosingParty'] ?? _formData['payeeName'],
        contractValue: _formData['serviceAmount'] != null 
            ? double.tryParse(_formData['serviceAmount'].toString())
            : _formData['totalAmount'] != null 
                ? double.tryParse(_formData['totalAmount'].toString())
                : _formData['compensationAmount'] != null
                    ? double.tryParse(_formData['compensationAmount'].toString())
                    : null,
      );

      final contractId = await _firebaseService.createContract(contract);
      
      // Decrement user's contract count
      await _firebaseService.decrementUserContracts(currentUser.uid);

      if (mounted) {
        context.go('/contract-preview?id=$contractId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating contract: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_template['title']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create ${_template['title']}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fill out the form below to generate your contract. All required fields must be completed.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                ...(_template['fields'] as List).map((field) => _buildFormField(field)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Generate Contract',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    final key = field['key'];
    final label = field['label'];
    final type = field['type'];
    final required = field['required'] ?? false;
    final options = field['options'] as List<String>?;
    final placeholder = field['placeholder'] as String?;

    Widget formField;

    switch (type) {
      case 'text':
        formField = TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            hintText: placeholder,
          ),
          validator: required ? (value) => Validators.validateRequired(value, label) : null,
        );
        break;

      case 'textarea':
        formField = TextFormField(
          controller: _controllers[key],
          maxLines: 4,
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            hintText: placeholder,
            alignLabelWithHint: true,
          ),
          validator: required ? (value) => Validators.validateRequired(value, label) : null,
        );
        break;

      case 'number':
        formField = TextFormField(
          controller: _controllers[key],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            prefixText: '\$',
          ),
          validator: required ? Validators.validateAmount : null,
        );
        break;

      case 'date':
        formField = TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
            );
            if (date != null) {
              _controllers[key]!.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
          validator: required ? Validators.validateDate : null,
        );
        break;

      case 'select':
        formField = DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          items: options?.map((option) => DropdownMenuItem(
            value: option,
            child: Text(option),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _formData[key] = value;
            });
          },
          validator: required ? (value) => value == null ? '$label is required' : null : null,
        );
        break;

      case 'multiselect':
        formField = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label + (required ? ' *' : ''),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Wrap(
                children: options?.map((option) {
                  final isSelected = (_formData[key] as List<String>?)?.contains(option) ?? false;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: FilterChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _formData[key] ??= <String>[];
                          final list = _formData[key] as List<String>;
                          if (selected) {
                            list.add(option);
                          } else {
                            list.remove(option);
                          }
                        });
                      },
                    ),
                  );
                }).toList() ?? [],
              ),
            ),
          ],
        );
        break;

      default:
        formField = TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: label + (required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          validator: required ? (value) => Validators.validateRequired(value, label) : null,
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: formField,
    );
  }
}