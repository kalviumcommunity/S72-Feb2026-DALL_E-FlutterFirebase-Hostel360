# Hostel360

A Flutter-based complaint management system for college hostels.

## Project Setup

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase CLI
- Android Studio / Xcode (for mobile development)

### Firebase Configuration

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project named "Hostel360"
   - Enable Firebase Authentication, Firestore, and Cloud Messaging

2. **Configure Firebase for Flutter**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your Flutter project
   flutterfire configure
   ```
   
   This will generate the `lib/firebase_options.dart` file with your actual Firebase credentials.

3. **Deploy Firestore Security Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

4. **Add google-services.json (Android)**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/google-services.json`

5. **Add GoogleService-Info.plist (iOS)**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/GoogleService-Info.plist`

### Installation

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Project Structure

```
lib/
├── models/          # Data models (Complaint, User, etc.)
├── services/        # Business logic services (AuthService, ComplaintService, etc.)
├── providers/       # State management providers
├── screens/         # UI screens
├── widgets/         # Reusable UI components
├── firebase_options.dart  # Firebase configuration
└── main.dart        # App entry point
```

## Features

- **Authentication**: Email/password authentication with role-based access
- **Complaint Management**: Submit and track complaints
- **Real-time Updates**: Live synchronization with Firestore
- **Offline Support**: Works offline with automatic sync when online
- **Dark Mode**: Light and dark theme support
- **Push Notifications**: Status update notifications
- **Smooth Animations**: Polished UI with transitions

## Firebase Services

- **Firebase Auth**: User authentication
- **Cloud Firestore**: Database with offline persistence enabled
- **Firebase Cloud Messaging**: Push notifications
- **Cloud Functions**: Automated notification triggers

## Security

Firestore security rules enforce:
- Students can only read/write their own complaints
- Admins can read all complaints and update status
- All operations require authentication
- Complaint deletion is disabled

## Development Timeline

This project follows a 15-day development schedule:
- Days 5-6: Project setup and Flutter basics ✓
- Days 7-9: Authentication with dark mode
- Days 10-12: Complaint management with animations
- Days 13-15: Admin features, push notifications, and testing

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

Target: 80%+ code coverage with property-based testing for correctness properties.
