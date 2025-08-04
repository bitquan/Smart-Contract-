# Smart Contract Generator

A Flutter web application for generating professional legal contracts with digital signatures and payment processing.

## Features

### Core Functionality
- **8 Contract Templates**: Service Agreement, NDA, Payment Terms, Independent Contractor Agreement, Photography Release, Home Service Agreement, Freelance Agreement, Social Media Contract
- **Digital Signatures**: Built-in signature pad with timestamp and IP tracking
- **PDF Generation**: Professional PDF contracts with custom branding
- **Firebase Integration**: User authentication, data storage, and file hosting
- **Stripe Payment Processing**: Subscription management and one-time payments

### Pricing Model
- **Free Tier**: 1 contract generation
- **Pro Plan**: $5/month for 3 contracts per month
- **Additional Contracts**: $1 per additional contract

## Setup Instructions

### 1. Firebase Configuration
1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password and Google)
3. Enable Firestore Database
4. Enable Storage
5. Copy your Firebase configuration and update `lib/main.dart`

### 2. Stripe Configuration
1. Create a Stripe account at [Stripe Dashboard](https://dashboard.stripe.com/)
2. Get your API keys (publishable and secret)
3. Create price objects for your subscription plans
4. Update `lib/services/stripe_service.dart` with your keys

### 3. Development Setup
```bash
# Install Flutter dependencies
flutter pub get

# Run the web application
flutter run -d web-server --web-port 8080
```

### 4. Production Deployment
```bash
# Build for production
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

## Revenue Model

The app is designed for immediate revenue generation with a freemium model:
- Free tier converts users with 1 free contract
- Low-friction upgrade to $5/month Pro plan
- Additional revenue from $1 one-time contract purchases
- High-converting contract templates solve real pain points

## License

This project is proprietary software. All rights reserved.