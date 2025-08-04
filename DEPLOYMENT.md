# Smart Contract Generator - Deployment Guide

## Quick Start

This Smart Contract Generator is a complete MVP ready for deployment. Follow these steps to get it running:

### 1. Prerequisites
- Flutter SDK (latest stable version)
- Firebase account
- Stripe account
- Domain name (optional, for custom hosting)

### 2. Firebase Setup (Required)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable the following services:
   - **Authentication**: Email/Password and Google providers
   - **Firestore Database**: Start in test mode, then configure security rules
   - **Storage**: Default settings
   - **Hosting**: For web deployment

4. Get your Firebase config and update `lib/main.dart`:
```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "your-actual-api-key",
    authDomain: "your-project.firebaseapp.com",
    projectId: "your-project-id", 
    storageBucket: "your-project.appspot.com",
    messagingSenderId: "your-sender-id",
    appId: "your-app-id",
  ),
);
```

### 3. Stripe Setup (Required for Payments)
1. Create account at [Stripe Dashboard](https://dashboard.stripe.com/)
2. Get your API keys from the dashboard
3. Create these products/prices:
   - **Pro Plan**: $5/month recurring subscription
   - **Additional Contract**: $1 one-time payment

4. Update `lib/services/stripe_service.dart`:
```dart
static const String _publishableKey = 'pk_live_your_actual_key';
static const String _secretKey = 'sk_live_your_actual_key'; 
```

### 4. Deploy to Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init hosting

# Build the Flutter web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### 5. Set Up Security Rules

**Firestore Rules** (replace the default rules):
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read/write their own contracts
    match /contracts/{contractId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

**Storage Rules**:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /contracts/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Revenue Configuration

The app is configured with these pricing tiers:
- **Free**: 1 contract
- **Pro Plan**: $5/month for 3 contracts  
- **Additional**: $1 per extra contract

To maximize revenue:
1. Set up Stripe webhooks for subscription events
2. Configure email notifications for conversions
3. Add analytics tracking (Firebase Analytics)
4. Set up customer support system

## Post-Deployment Checklist

- [ ] Test user registration and login
- [ ] Verify contract generation works
- [ ] Test PDF download functionality  
- [ ] Confirm digital signatures save properly
- [ ] Test subscription payment flow
- [ ] Verify one-time payments work
- [ ] Check mobile responsiveness
- [ ] Test all 8 contract templates
- [ ] Set up domain name (optional)
- [ ] Configure SSL certificate
- [ ] Set up monitoring and alerts

## Monitoring & Analytics

Add these to track success:
- Firebase Analytics for user behavior
- Stripe Dashboard for payment monitoring  
- Google Analytics for web traffic
- Error reporting with Firebase Crashlytics

## Support & Maintenance

- Monitor Firestore usage for scaling needs
- Review Stripe transaction fees
- Update contract templates based on legal requirements
- Regular security updates for dependencies
- Backup Firestore data regularly

## Scaling Considerations

As you grow:
- Implement caching for contract templates
- Add CDN for faster PDF delivery
- Consider dedicated customer support
- Add more payment methods beyond Stripe
- Implement affiliate/referral program
- Add team/organization features

Your Smart Contract Generator MVP is now ready to start generating revenue!