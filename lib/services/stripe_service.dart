import 'package:http/http.dart' as http;
import 'dart:convert';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  // These should be environment variables in production
  static const String _publishableKey = 'pk_test_your_publishable_key_here';
  static const String _secretKey = 'sk_test_your_secret_key_here';
  static const String _baseUrl = 'https://api.stripe.com/v1';

  // Price IDs for the subscription plans (created in Stripe dashboard)
  static const String _proPlanPriceId = 'price_pro_plan_monthly';

  Future<bool> createSubscription({
    required String userId,
    required String email,
  }) async {
    try {
      // In a real implementation, this would:
      // 1. Create a customer in Stripe
      // 2. Create a subscription with the Pro plan price
      // 3. Handle payment method collection (Stripe Elements)
      // 4. Process the subscription

      // For now, we'll simulate a successful subscription
      // In production, you'd use Stripe's actual API or SDK

      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Simulate success rate of 90%
      return DateTime.now().millisecond % 10 != 0;
    } catch (e) {
      print('Stripe subscription error: $e');
      return false;
    }
  }

  Future<bool> processOneTimePayment({
    required int amount, // Amount in cents
    required String userId,
    required String email,
  }) async {
    try {
      // In a real implementation, this would:
      // 1. Create a payment intent
      // 2. Confirm the payment with payment method
      // 3. Handle payment success/failure

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      // Simulate success rate of 95%
      return DateTime.now().millisecond % 20 != 0;
    } catch (e) {
      print('Stripe payment error: $e');
      return false;
    }
  }

  Future<bool> cancelSubscription({required String subscriptionId}) async {
    try {
      // Cancel subscription in Stripe
      final response = await http.delete(
        Uri.parse('$_baseUrl/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Stripe cancellation error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> createCustomer({
    required String email,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'name': name,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Stripe customer creation error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent({
    required int amount,
    required String currency,
    required String customerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'customer': customerId,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Stripe payment intent error: $e');
      return null;
    }
  }

  Future<bool> handleWebhook({
    required String payload,
    required String signature,
  }) async {
    try {
      // Verify webhook signature
      // Handle different webhook events:
      // - payment_intent.succeeded
      // - customer.subscription.created
      // - customer.subscription.updated
      // - customer.subscription.deleted
      // - invoice.payment_succeeded
      // - invoice.payment_failed

      final data = json.decode(payload);
      final eventType = data['type'];

      switch (eventType) {
        case 'customer.subscription.created':
          // Handle new subscription
          break;
        case 'customer.subscription.updated':
          // Handle subscription updates
          break;
        case 'customer.subscription.deleted':
          // Handle subscription cancellation
          break;
        case 'invoice.payment_succeeded':
          // Handle successful payment
          break;
        case 'invoice.payment_failed':
          // Handle failed payment
          break;
        default:
          print('Unhandled webhook event: $eventType');
      }

      return true;
    } catch (e) {
      print('Webhook handling error: $e');
      return false;
    }
  }

  // Helper method to get price information
  static Map<String, dynamic> getPricingInfo() {
    return {
      'freePlan': {
        'contracts': 1,
        'price': 0,
        'features': [
          '1 contract generation',
          'All contract templates',
          'Digital signatures',
          'PDF generation',
        ],
      },
      'proPlan': {
        'contracts': 3,
        'price': 5, // $5 per month
        'features': [
          '3 contracts per month',
          'All contract templates',
          'Digital signatures',
          'PDF generation',
          'Priority support',
          'Email delivery',
        ],
      },
      'additionalContract': {
        'price': 1, // $1 per additional contract
      },
    };
  }

  // Method to validate payment amounts
  static bool isValidAmount(int amount) {
    final pricing = getPricingInfo();
    return amount == (pricing['proPlan']['price'] * 100) || // Pro plan
           amount == (pricing['additionalContract']['price'] * 100); // Additional contract
  }
}