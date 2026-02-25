# Hostel360 Setup Guide

## Current Branch: feature/task-16-screen-transitions

This branch has:
- ✅ Login/Signup screens
- ✅ Theme management
- ✅ Page transitions
- ✅ Auth and Complaint providers
- ⚠️ Missing: UI widgets (they're on feature/task-9-ui-components branch)

## Quick Setup to Run

### 1. Add Firebase Configuration

**CRITICAL:** The app won't run without these files!

#### For Android:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings → Your Apps → Android App
4. Download `google-services.json`
5. Place it here: `android/app/google-services.json`

#### For iOS:
1. In Firebase Console → Project Settings → Your Apps → iOS App
2. Download `GoogleService-Info.plist`
3. Place it here: `ios/Runner/GoogleService-Info.plist`

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

Or in Android Studio: Click the green Run button (▶️)

## What You'll See

Since this branch doesn't have all the UI components, you'll see:
- ✅ Login screen (working)
- ✅ Signup screen (working)
- ⚠️ After login: May have errors because home screens are on other branches

## To Test Full Functionality

### Option 1: Merge All Feature Branches
1. Create and merge PR for `feature/task-9-ui-components` first
2. Then merge other feature branches in order
3. All features will work together

### Option 2: Test Individual Branches

**Test UI Components (Task 9):**
```bash
git checkout feature/task-9-ui-components
flutter run
```

**Test Student Interface (Task 10):**
```bash
git checkout feature/task-10-student-interface
flutter run
```

**Test Admin Interface (Task 11):**
```bash
git checkout feature/task-11-admin-interface
flutter run
```

## Common Errors & Solutions

### Error: "No Firebase App"
**Solution:** Add `google-services.json` and `GoogleService-Info.plist`

### Error: "Widget not found"
**Solution:** You're on a branch that doesn't have all widgets. Switch to a different branch or merge the feature branches.

### Error: "Build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

## Firebase Setup (If Not Done)

1. Create a Firebase project at https://console.firebase.google.com/
2. Enable Authentication → Email/Password
3. Create Firestore Database
4. Add Android/iOS apps to your Firebase project
5. Download configuration files

## Next Steps

1. Add Firebase config files
2. Run `flutter pub get`
3. Run `flutter run`
4. Test login/signup functionality
5. Create pull requests for feature branches
6. Merge them to get full functionality
