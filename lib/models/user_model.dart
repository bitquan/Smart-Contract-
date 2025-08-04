class UserModel {
  final String id;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final int contractsRemaining;
  final bool hasActiveSubscription;
  final String? subscriptionId;
  final DateTime? subscriptionEndDate;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.createdAt,
    this.contractsRemaining = 1, // Free tier gets 1 contract
    this.hasActiveSubscription = false,
    this.subscriptionId,
    this.subscriptionEndDate,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      contractsRemaining: map['contractsRemaining'] ?? 1,
      hasActiveSubscription: map['hasActiveSubscription'] ?? false,
      subscriptionId: map['subscriptionId'],
      subscriptionEndDate: map['subscriptionEndDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['subscriptionEndDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'contractsRemaining': contractsRemaining,
      'hasActiveSubscription': hasActiveSubscription,
      'subscriptionId': subscriptionId,
      'subscriptionEndDate': subscriptionEndDate?.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    int? contractsRemaining,
    bool? hasActiveSubscription,
    String? subscriptionId,
    DateTime? subscriptionEndDate,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      contractsRemaining: contractsRemaining ?? this.contractsRemaining,
      hasActiveSubscription: hasActiveSubscription ?? this.hasActiveSubscription,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }
}