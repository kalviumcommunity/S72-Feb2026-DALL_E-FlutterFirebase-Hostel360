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

Performance Considerations & UI Responsiveness
Why Improper State Management Causes UI Lag

Flutter renders the UI at 60–120 frames per second, which means each frame must be built and painted in roughly 16 ms (or less). Improper state handling can easily break this budget and cause dropped frames, jank, or visible UI lag.

Common causes include:

1. Unnecessary Widget Rebuilds

Calling setState() too high in the widget tree forces all child widgets to rebuild, even when only a small part of the UI has changed.

Impact:

Increased build cost per frame

Layout and paint work repeated unnecessarily

Frame deadlines missed → stuttering animations

Mitigation:

Keep state as close as possible to the widget that uses it

Use Consumer, Selector, or granular providers to limit rebuild scope

2. Rebuilding Heavy Widgets Repeatedly

Complex widgets such as lists, animations, and image-heavy components are expensive to rebuild.

Impact:

CPU spikes during build phase

Scroll lag and delayed touch responses

Mitigation:

Mark static widgets as const

Use ListView.builder instead of ListView

Cache data and UI where possible

3. Performing Business Logic in build()

Placing database calls, sorting logic, or computations inside build() causes them to run every time the widget rebuilds.

Impact:

Blocking the UI thread

Inconsistent frame rendering

Mitigation:

Move logic to services or providers

Trigger side effects in lifecycle methods or async callbacks

Flutter’s Reactive Rendering Model

Flutter uses a reactive UI paradigm, where the UI is a pure function of state.

How It Works

State changes (e.g., Firestore update, user action)

Flutter marks affected widgets as dirty

Only those widgets are rebuilt

Render tree is diffed and updated efficiently

Why This Improves Performance

Minimal rebuilds instead of full UI refresh

Predictable rendering behavior

Efficient reconciliation of UI changes

This makes Flutter especially well-suited for real-time apps like Hostel360, where complaint status updates must reflect instantly without re-rendering the entire screen.

Dart’s Asynchronous Model & Smooth Performance

Flutter runs on a single UI thread, so blocking operations can freeze the interface. Dart’s async model prevents this.

Key Components
1. async / await

Time-consuming operations (network calls, Firestore reads, authentication) are executed asynchronously without blocking the UI thread.

final complaints = await complaintService.fetchComplaints();


Benefit:

UI remains responsive

Animations and scrolling stay smooth

2. Event Loop & Futures

Dart uses an event loop that schedules async tasks and callbacks efficiently.

Benefit:

Background operations are handled without frame drops

State updates are applied only when data is ready

3. Streams for Real-Time Updates

Firestore streams push updates incrementally rather than reloading all data.

StreamBuilder(
  stream: complaintService.complaintsStream(),
  builder: (context, snapshot) { ... }
)


Benefit:

Real-time UI updates

No polling or unnecessary rebuilds

Efficient memory usage

Cross-Platform Consistency

Flutter renders using Skia, its own graphics engine, instead of native OEM widgets.

Advantages

Identical performance across Android & iOS

No platform-specific rendering inconsistencies

Smooth animations and transitions on all devices

Combined with:

Reactive rendering

Async-first execution

Fine-grained state updates

Flutter maintains a stable frame rate and smooth user experience even under real-time data loads.

Case Study: “The App That Looked Perfect, But Only on One Phone”
Problem: Why Static Designs Fail Across Devices

Early UI iterations of Hostel360 were designed using fixed pixel values based on Figma mockups. While this looked perfect on a reference device, it failed on:

Smaller phones → overlapping text, clipped buttons

Larger tablets → excessive whitespace, awkward spacing

Different platforms (Android vs iOS) → inconsistent visual balance

Root Causes of Static Layouts

Fixed Widths & Heights

Container(width: 300, height: 200)


Works only for a specific screen size

Breaks on smaller or larger devices

Rigid Padding & Margins

Absolute spacing doesn’t scale with screen density

Leads to crowded or overly sparse layouts

Ignoring Aspect Ratios

Phones, tablets, and foldables all have different proportions

A one-size layout fails visually and functionally

Solution: Responsive Flutter Layout Strategy

To preserve the original Figma design intent while supporting all screen sizes, Hostel360 adopts Flutter’s adaptive layout system.

1. MediaQuery – Screen-Aware Sizing

Used to scale UI elements relative to screen dimensions instead of hardcoded pixels.

final screenWidth = MediaQuery.of(context).size.width;

Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
)


✅ Ensures consistent spacing on small phones and large tablets
✅ Maintains proportional design across devices

2. Flexible & Expanded – Dynamic Space Distribution

Prevents overflow and overlap in rows and columns.

Row(
  children: [
    Expanded(child: ComplaintCard()),
    Flexible(child: StatusBadge()),
  ],
)


✅ Automatically adjusts based on available space
✅ Prevents UI breakage on narrow screens
✅ Keeps layouts fluid instead of rigid

3. LayoutBuilder – Constraint-Based Decisions

Used where layout behavior must change based on screen width.

LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return TabletLayout();
    } else {
      return MobileLayout();
    }
  },
)


✅ Enables adaptive layouts instead of stretched ones
✅ Allows tablet-specific UI without duplicating screens
✅ Preserves usability across form factors

4. Responsive Typography & Components

Font sizes and UI elements scale based on screen size:

Text(
  'Complaint Status',
  style: Theme.of(context).textTheme.titleMedium,
)


Combined with:

ThemeData

Platform-aware defaults

Scaled paddings instead of fixed font sizes

✅ Improves readability
✅ Prevents text clipping
✅ Ensures accessibility consistency

Result: Design Fidelity + Cross-Device Reliability

By replacing static pixel-based layouts with responsive Flutter widgets:

✅ No overlapping UI on small phones

✅ Balanced spacing on tablets

✅ Consistent look across Android & iOS

✅ Original Figma design intent preserved

✅ Future-proof for new screen sizes

This approach ensures Hostel360 delivers a polished, production-grade user experience, regardless of device size or platform — solving the exact problem seen in the FlexiFit case study.

## API Documentation (Bruno)

All Firebase REST API requests used in this project are documented using Bruno.

Location:
docs/bruno/Flutter-Firebase API Documentation/

Includes:
- Authentication endpoints
- Firestore operations
- Storage requests
- Example request bodies
- Example responses
- Environment variables for tokens
