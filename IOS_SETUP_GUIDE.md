# iOS Setup Guide for Hostel360

## Current Status
- ✅ iOS folder structure exists
- ✅ All Dart code is cross-platform ready
- ❌ Firebase not configured for iOS yet

---

## Step-by-Step iOS Configuration

### Step 1: Add iOS App to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **hostel360-ccad5**
3. Click the **iOS icon** (⊕ Add app)
4. Fill in the details:
   - **iOS bundle ID**: `com.example.hostel360`
   - **App nickname** (optional): Hostel360 iOS
   - **App Store ID** (optional): Leave blank for now
5. Click **Register app**

---

### Step 2: Download GoogleService-Info.plist

1. After registering, Firebase will show a download button
2. Click **Download GoogleService-Info.plist**
3. Save the file (you'll need it in the next step)

**Important**: This file contains your iOS Firebase configuration (like `google-services.json` for Android)

---

### Step 3: Add GoogleService-Info.plist to Xcode

**Option A: Using Xcode (Recommended)**

1. Open your project in Xcode:
   ```bash
   cd S72-Feb2026-DALL_E-FlutterFirebase-Hostel360
   open ios/Runner.xcworkspace
   ```

2. In Xcode, right-click on **Runner** folder (in the left sidebar)
3. Select **Add Files to "Runner"...**
4. Navigate to your downloaded `GoogleService-Info.plist`
5. **IMPORTANT**: Check these boxes:
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ Add to targets: Runner
6. Click **Add**

**Option B: Manual Copy (If you don't have Xcode)**

1. Copy the file to the Runner folder:
   ```bash
   cp ~/Downloads/GoogleService-Info.plist ios/Runner/
   ```

2. You'll need to add it to Xcode later when you have access to a Mac

---

### Step 4: Update Info.plist (Required Permissions)

The `ios/Runner/Info.plist` file needs to be updated with required permissions.

Open `ios/Runner/Info.plist` and add these entries before the closing `</dict>` tag:

```xml
<!-- Camera permission (for image attachments) -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to let you attach photos to complaints</string>

<!-- Photo library permission (for image attachments) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to let you attach images to complaints</string>

<!-- Internet access (already included by default, but good to verify) -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

---

### Step 5: Update firebase_options.dart (Optional but Recommended)

Run the FlutterFire CLI to regenerate Firebase options with iOS support:

```bash
# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase for both platforms
flutterfire configure
```

This will:
- Detect your Firebase project
- Update `lib/firebase_options.dart` with iOS configuration
- Ensure both Android and iOS are properly configured

---

### Step 6: Install CocoaPods Dependencies

iOS uses CocoaPods for dependency management:

```bash
cd ios
pod install
cd ..
```

If you get errors, try:
```bash
cd ios
pod repo update
pod install
cd ..
```

---

### Step 7: Build and Run on iOS

**Using iOS Simulator:**
```bash
flutter run -d ios
```

**Using Physical iPhone:**
1. Connect your iPhone via USB
2. Trust the computer on your iPhone
3. Run:
   ```bash
   flutter devices  # Find your device ID
   flutter run -d <device-id>
   ```

---

## Troubleshooting

### Error: "No such module 'Firebase'"

**Solution**: Run pod install
```bash
cd ios
pod install
cd ..
```

### Error: "Code signing required"

**Solution**: Open Xcode and configure signing
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** in the left sidebar
3. Go to **Signing & Capabilities** tab
4. Select your **Team** (you may need an Apple Developer account)
5. Xcode will automatically manage signing

### Error: "GoogleService-Info.plist not found"

**Solution**: Make sure you added the file correctly in Step 3

### Error: "Minimum deployment target"

**Solution**: Update `ios/Podfile`
```ruby
platform :ios, '12.0'  # Change to at least 12.0
```

Then run:
```bash
cd ios
pod install
cd ..
```

---

## Verification Checklist

After setup, verify everything works:

- [ ] `GoogleService-Info.plist` is in `ios/Runner/` folder
- [ ] Info.plist has camera and photo library permissions
- [ ] `pod install` completed successfully
- [ ] App builds without errors: `flutter build ios`
- [ ] Firebase Auth works (can login/signup)
- [ ] Firestore works (can create/read complaints)

---

## iOS-Specific Notes

### Differences from Android:

1. **Permissions**: iOS requires explicit permission descriptions in Info.plist
2. **Dependencies**: Uses CocoaPods instead of Gradle
3. **Build System**: Uses Xcode instead of Android Studio
4. **Signing**: Requires Apple Developer account for physical devices

### What's Already Cross-Platform:

✅ All Dart code (100% of your app logic)  
✅ UI components (Material Design works on iOS)  
✅ Firebase integration (same API on both platforms)  
✅ State management (Provider works identically)  
✅ All features from Batch 1-6

---

## Quick Start (TL;DR)

If you just want to get it running quickly:

```bash
# 1. Add iOS app in Firebase Console and download GoogleService-Info.plist

# 2. Copy the file
cp ~/Downloads/GoogleService-Info.plist ios/Runner/

# 3. Install dependencies
cd ios && pod install && cd ..

# 4. Run on iOS
flutter run -d ios
```

---

## Need Help?

Common issues:
- **No Mac?** You can still develop on Android. iOS requires macOS for building.
- **No Apple Developer Account?** You can still test on simulator (free).
- **Physical device testing?** Requires Apple Developer account ($99/year).

---

## Next Steps

Once iOS is configured:
1. Test all features on iOS simulator
2. Verify Firebase Auth works
3. Test complaint creation/editing
4. Test image uploads (when we add that feature)
5. Build for TestFlight (optional, for beta testing)

Your app is already 100% ready for iOS - just needs the Firebase configuration file!
