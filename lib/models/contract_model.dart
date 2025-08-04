enum ContractType {
  serviceAgreement,
  nda,
  paymentTerms,
  contractorAgreement,
  photographyRelease,
  homeService,
  freelanceAgreement,
  socialMediaContract,
}

enum ContractStatus {
  draft,
  awaitingSignature,
  signed,
  completed,
}

class ContractModel {
  final String id;
  final String userId;
  final ContractType type;
  final ContractStatus status;
  final Map<String, dynamic> formData;
  final DateTime createdAt;
  final DateTime? signedAt;
  final String? pdfUrl;
  final String? clientSignature;
  final String? providerSignature;
  final String? clientName;
  final String? providerName;
  final String? clientEmail;
  final String? providerEmail;
  final double? contractValue;

  ContractModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.formData,
    required this.createdAt,
    this.signedAt,
    this.pdfUrl,
    this.clientSignature,
    this.providerSignature,
    this.clientName,
    this.providerName,
    this.clientEmail,
    this.providerEmail,
    this.contractValue,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: ContractType.values[map['type'] ?? 0],
      status: ContractStatus.values[map['status'] ?? 0],
      formData: Map<String, dynamic>.from(map['formData'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      signedAt: map['signedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['signedAt'])
          : null,
      pdfUrl: map['pdfUrl'],
      clientSignature: map['clientSignature'],
      providerSignature: map['providerSignature'],
      clientName: map['clientName'],
      providerName: map['providerName'],
      clientEmail: map['clientEmail'],
      providerEmail: map['providerEmail'],
      contractValue: map['contractValue']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.index,
      'status': status.index,
      'formData': formData,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'signedAt': signedAt?.millisecondsSinceEpoch,
      'pdfUrl': pdfUrl,
      'clientSignature': clientSignature,
      'providerSignature': providerSignature,
      'clientName': clientName,
      'providerName': providerName,
      'clientEmail': clientEmail,
      'providerEmail': providerEmail,
      'contractValue': contractValue,
    };
  }

  String get typeDisplayName {
    switch (type) {
      case ContractType.serviceAgreement:
        return 'Service Agreement';
      case ContractType.nda:
        return 'Non-Disclosure Agreement';
      case ContractType.paymentTerms:
        return 'Payment Terms Agreement';
      case ContractType.contractorAgreement:
        return 'Independent Contractor Agreement';
      case ContractType.photographyRelease:
        return 'Photography/Videography Release';
      case ContractType.homeService:
        return 'Home Service Agreement';
      case ContractType.freelanceAgreement:
        return 'Freelance Work Agreement';
      case ContractType.socialMediaContract:
        return 'Social Media Management Contract';
    }
  }

  ContractModel copyWith({
    String? id,
    String? userId,
    ContractType? type,
    ContractStatus? status,
    Map<String, dynamic>? formData,
    DateTime? createdAt,
    DateTime? signedAt,
    String? pdfUrl,
    String? clientSignature,
    String? providerSignature,
    String? clientName,
    String? providerName,
    String? clientEmail,
    String? providerEmail,
    double? contractValue,
  }) {
    return ContractModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      signedAt: signedAt ?? this.signedAt,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      clientSignature: clientSignature ?? this.clientSignature,
      providerSignature: providerSignature ?? this.providerSignature,
      clientName: clientName ?? this.clientName,
      providerName: providerName ?? this.providerName,
      clientEmail: clientEmail ?? this.clientEmail,
      providerEmail: providerEmail ?? this.providerEmail,
      contractValue: contractValue ?? this.contractValue,
    );
  }
}