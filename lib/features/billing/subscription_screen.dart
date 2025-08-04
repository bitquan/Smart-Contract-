import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import '../../services/stripe_service.dart';
import '../../models/user_model.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _firebaseService = FirebaseService();
  final _stripeService = StripeService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isProcessing = false;

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

  Future<void> _subscribeToPro() async {
    if (_user == null) return;

    setState(() => _isProcessing = true);

    try {
      // Create Stripe subscription
      final success = await _stripeService.createSubscription(
        userId: _user!.id,
        email: _user!.email,
      );

      if (success) {
        // Update user with subscription
        final updatedUser = _user!.copyWith(
          hasActiveSubscription: true,
          contractsRemaining: 3, // Pro plan gets 3 contracts per month
          subscriptionEndDate: DateTime.now().add(const Duration(days: 30)),
        );
        
        await _firebaseService.updateUserDocument(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully upgraded to Pro!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _buyAdditionalContract() async {
    if (_user == null) return;

    setState(() => _isProcessing = true);

    try {
      // Process one-time payment for additional contract
      final success = await _stripeService.processOneTimePayment(
        amount: 100, // $1.00 in cents
        userId: _user!.id,
        email: _user!.email,
      );

      if (success) {
        // Update user with additional contract
        final updatedUser = _user!.copyWith(
          contractsRemaining: _user!.contractsRemaining + 1,
        );
        
        await _firebaseService.updateUserDocument(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Additional contract purchased!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _user = updatedUser;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
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
        title: const Text('Upgrade Your Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Status
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _user!.hasActiveSubscription 
                      ? Colors.green.shade50 
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _user!.hasActiveSubscription 
                        ? Colors.green.shade200 
                        : Colors.orange.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _user!.hasActiveSubscription 
                              ? Icons.check_circle 
                              : Icons.warning,
                          color: _user!.hasActiveSubscription 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _user!.hasActiveSubscription 
                              ? 'Pro Plan Active' 
                              : 'Free Plan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _user!.hasActiveSubscription 
                                ? Colors.green.shade800 
                                : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contracts remaining: ${_user!.contractsRemaining}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_user!.hasActiveSubscription && _user!.subscriptionEndDate != null)
                      Text(
                        'Renews on: ${_formatDate(_user!.subscriptionEndDate!)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Pricing Plans
              const Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Free Plan Card
              _buildPlanCard(
                title: 'Free Plan',
                price: '\$0',
                period: 'forever',
                features: [
                  '1 contract generation',
                  'All contract templates',
                  'Digital signatures',
                  'PDF generation',
                ],
                isCurrentPlan: !_user!.hasActiveSubscription,
                buttonText: 'Current Plan',
                onTap: null,
                highlighted: false,
              ),
              const SizedBox(height: 16),

              // Pro Plan Card
              _buildPlanCard(
                title: 'Pro Plan',
                price: '\$5',
                period: 'per month',
                features: [
                  '3 contracts per month',
                  'All contract templates',
                  'Digital signatures',
                  'PDF generation',
                  'Priority support',
                  'Email delivery',
                ],
                isCurrentPlan: _user!.hasActiveSubscription,
                buttonText: _user!.hasActiveSubscription 
                    ? 'Current Plan' 
                    : 'Upgrade to Pro',
                onTap: _user!.hasActiveSubscription ? null : _subscribeToPro,
                highlighted: true,
              ),
              const SizedBox(height: 32),

              // One-time Purchase
              if (!_user!.hasActiveSubscription) ...[
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Need Just One More Contract?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Additional Contract',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'One-time purchase',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            '\$1',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _buyAdditionalContract,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isProcessing
                              ? const CircularProgressIndicator()
                              : const Text('Buy One Contract'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // FAQ Section
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFAQItem(
                'What happens after my free contract?',
                'You can either upgrade to Pro for \$5/month to get 3 contracts monthly, or purchase additional contracts for \$1 each.',
              ),
              _buildFAQItem(
                'Can I cancel my Pro subscription?',
                'Yes, you can cancel anytime. You\'ll continue to have access until the end of your billing period.',
              ),
              _buildFAQItem(
                'Are the contracts legally binding?',
                'Yes, all contracts generated are legally valid with digital signatures, timestamps, and IP tracking for legal compliance.',
              ),
              _buildFAQItem(
                'Do unused contracts roll over?',
                'Pro plan contracts reset each month. One-time purchases add permanent contracts to your account.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrentPlan,
    required String buttonText,
    required VoidCallback? onTap,
    required bool highlighted,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: highlighted ? Colors.blue : Colors.grey.shade300,
          width: highlighted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: highlighted ? Colors.blue.shade50 : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (highlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: price,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: ' $period',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(feature, style: const TextStyle(fontSize: 14)),
                ],
              ),
            )),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlighted ? Colors.blue : Colors.grey.shade200,
                  foregroundColor: highlighted ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isProcessing && onTap != null
                    ? const CircularProgressIndicator()
                    : Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              answer,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}