# Hostel360 Setup Guide

## Initial Setup Checklist

### 1. Flutter Environment Setup
- [ ] Install Flutter SDK (3.0.0+)
- [ ] Run `flutter doctor` to verify installation
- [ ] Set up Android Studio or Xcode for mobile development

### 2. Firebase Project Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name it "Hostel360"
4. Disable Google Analytics (optional)
5. Click "Create project"

#### Enable Firebase Services
1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password" provider
   - Click "Save"

2. **Cloud Firestore**
   - Go to Firestore Database
   - Click "Create database"
   - Start in "Test mode" (we'll deploy security rules later)
   - Choose a location (e.g., us-central)
   - Click "Enable"

3. **Cloud Messaging**
   - Go to Project Settings → Cloud Messaging
   - Note your Server Key (for later use)

### 3. Configure Firebase for Flutter

#### Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Configure Firebase
```bash
cd S72-Feb2026-DALL_E-FlutterFirebase-Hostel360
flutterfire configure
```

This command will:
- Create/update `firebase_options.dart` with your Firebase credentials
- Generate platform-specific configuration files
- Link your Flutter app to your Firebase project

Select your Firebase project when prompted, and choose the platforms you want to support (Android, iOS, Web).

### 4. Add Platform-Specific Configuration

#### Android Configuration
1. Download `google-services.json` from Firebase Console:
   - Go to Project Settings → Your apps
   - Click on your Android app
   - Download `google-services.json`
   
2. Place it in: `android/app/google-services.json`

3. The `android/app/build.gradle` already includes Firebase dependencies

#### iOS Configuration
1. Download `GoogleService-Info.plist` from Firebase Console:
   - Go to Project Settings → Your apps
   - Click on your iOS app
   - Download `GoogleService-Info.plist`
   
2. Place it in: `ios/Runner/GoogleService-Info.plist`

3. Open `ios/Runner.xcworkspace` in Xcode
4. Drag `GoogleService-Info.plist` into the Runner folder in Xcode

### 5. Deploy Firestore Security Rules

```bash
# Initialize Firebase in your project (if not already done)
firebase init firestore

# Deploy security rules
firebase deploy --only firestore:rules
```

The security rules are already configured in `firestore.rules` and enforce:
- Students can only access their own complaints
- Admins can access all complaints
- All operations require authentication

### 6. Install Dependencies

```bash
flutter pub get
```

### 7. Verify Setup

```bash
# Check Flutter setup
flutter doctor

# Run the app
flutter run
```

You should see "Hostel360 - Setup Complete" on the screen.

### 8. Create Test Users (Optional)

You can create test users directly in Firebase Console:
1. Go to Authentication → Users
2. Click "Add user"
3. Create a student user: `student@test.com` / `password123`
4. Create an admin user: `admin@test.com` / `password123`

Then manually add role documents in Firestore:
1. Go to Firestore Database
2. Create collection: `users`
3. Add document with ID matching the user's UID:
   ```json
   {
     "uid": "user_uid_here",
     "email": "student@test.com",
     "role": "student",
     "createdAt": "2024-02-06T00:00:00Z"
   }
   ```

## Troubleshooting

### Firebase not initialized
- Ensure `firebase_options.dart` exists and has valid credentials
- Run `flutterfire configure` again

### Build errors on Android
- Ensure `google-services.json` is in `android/app/`
- Check that `minSdkVersion` is at least 21 in `android/app/build.gradle`

### Build errors on iOS
- Ensure `GoogleService-Info.plist` is added to Xcode project
- Run `pod install` in the `ios/` directory

### Firestore permission denied
- Deploy security rules: `firebase deploy --only firestore:rules`
- Ensure users are authenticated before accessing Firestore

## Next Steps

After setup is complete, proceed with implementing the remaining tasks:
- Task 2: Implement data models and enums
- Task 3: Implement form validation module
- Task 4: Implement authentication service and provider
- And so on...

Refer to `.kiro/specs/hostel360/tasks.md` for the complete implementation plan.
