# Firebase Cloud Functions

## Setup

1. Install Firebase CLI:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase in your project (if not already done):
```bash
firebase init functions
```

4. Install dependencies:
```bash
cd functions
npm install
```

## Deploy

Deploy all functions:
```bash
firebase deploy --only functions
```

Deploy specific function:
```bash
firebase deploy --only functions:sendComplaintStatusNotification
```

## Test Locally

Run functions emulator:
```bash
npm run serve
```

## Functions

### sendComplaintStatusNotification
Triggers when a complaint status is updated and sends a push notification to the user.
