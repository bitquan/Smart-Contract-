import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import '../../models/user_model.dart';
import '../../models/contract_model.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _firebaseService = FirebaseService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _firebaseService.currentUser;
    if (currentUser == null) {
      context.go('/login');
      return;
    }

    try {
      final user = await _firebaseService.getUserDocument(currentUser.uid);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await _firebaseService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  void _createContract(ContractType type) {
    if (_user != null && _user!.contractsRemaining > 0) {
      context.go('/contract-form/${type.name}');
    } else {
      context.go('/subscription');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('User data not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Contract Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${_user!.displayName}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contracts remaining: ${_user!.contractsRemaining}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  if (!_user!.hasActiveSubscription && _user!.contractsRemaining == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton(
                        onPressed: () => context.go('/subscription'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade800,
                        ),
                        child: const Text('Upgrade to Pro'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contract Templates Section
            const Text(
              'Choose a Contract Template',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildContractCard(
                  title: 'Service Agreement',
                  subtitle: 'For freelancers & contractors',
                  icon: Icons.handshake,
                  type: ContractType.serviceAgreement,
                ),
                _buildContractCard(
                  title: 'NDA',
                  subtitle: 'Non-disclosure agreement',
                  icon: Icons.security,
                  type: ContractType.nda,
                ),
                _buildContractCard(
                  title: 'Payment Terms',
                  subtitle: 'Clear payment conditions',
                  icon: Icons.payment,
                  type: ContractType.paymentTerms,
                ),
                _buildContractCard(
                  title: 'Contractor Agreement',
                  subtitle: 'Independent contractor terms',
                  icon: Icons.work,
                  type: ContractType.contractorAgreement,
                ),
                _buildContractCard(
                  title: 'Photography Release',
                  subtitle: 'Photo/video permissions',
                  icon: Icons.camera_alt,
                  type: ContractType.photographyRelease,
                ),
                _buildContractCard(
                  title: 'Home Service',
                  subtitle: 'Cleaning, repair, tutoring',
                  icon: Icons.home,
                  type: ContractType.homeService,
                ),
                _buildContractCard(
                  title: 'Freelance Agreement',
                  subtitle: 'Writers, designers, developers',
                  icon: Icons.laptop,
                  type: ContractType.freelanceAgreement,
                ),
                _buildContractCard(
                  title: 'Social Media Contract',
                  subtitle: 'Content management',
                  icon: Icons.social_distance,
                  type: ContractType.socialMediaContract,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Contracts Section
            const Text(
              'Recent Contracts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<ContractModel>>(
              stream: _firebaseService.getUserContracts(_user!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final contracts = snapshot.data ?? [];
                
                if (contracts.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'No contracts yet. Create your first contract above!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contracts.length,
                  itemBuilder: (context, index) {
                    final contract = contracts[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(contract.typeDisplayName),
                        subtitle: Text(
                          'Created: ${_formatDate(contract.createdAt)}',
                        ),
                        trailing: Text(
                          _getStatusText(contract.status),
                          style: TextStyle(
                            color: _getStatusColor(contract.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // Navigate to contract preview
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required ContractType type,
  }) {
    final canCreate = _user!.contractsRemaining > 0 || _user!.hasActiveSubscription;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _createContract(type),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: canCreate ? Colors.blue : Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canCreate ? Colors.black : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: canCreate ? Colors.grey.shade600 : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              if (!canCreate)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Upgrade Required',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}