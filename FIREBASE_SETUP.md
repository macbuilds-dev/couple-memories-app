# Firebase setup (Flutter — official)

Follow the [Firebase Flutter setup guide](https://firebase.google.com/docs/flutter/setup).

Project: **yaaram** (`yaaram-80842`)  
Android package: `com.yaaram.lovestory`

## 1. Install CLI tools

```bash
# Firebase CLI
npm install -g firebase-tools

# FlutterFire CLI
dart pub global activate flutterfire_cli
```

Add Dart global packages to PATH (one-time, PowerShell):

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:LOCALAPPDATA\Pub\Cache\bin", "User")
```

Restart the terminal, then `flutterfire --version` should work. Until then use:

```bash
dart pub global run flutterfire_cli:flutterfire configure -p yaaram-80842
```

## 2. Log in to Firebase

```bash
firebase login
```

Sign in with the Google account that owns the **yaaram** project.

## 3. Configure Flutter + Firebase (this is the main step)

From the project root:

```bash
cd d:\mac\personal\couple-memories-app
flutterfire configure -p yaaram-80842
```

This will:

- Let you select project **yaaram**
- Register Android / iOS / Web apps if needed
- Generate `lib/firebase_options.dart`
- Download `android/app/google-services.json`
- Download `ios/Runner/GoogleService-Info.plist`

## 4. Add plugins (already in pubspec.yaml)

```bash
flutter pub add firebase_core firebase_auth cloud_firestore
flutterfire configure -p yaaram-80842
```

## 5. Initialize Firebase (already in `lib/main.dart`)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 6. Firebase Console setup (Spark plan — no CLI deploy needed)

**Spark (free) is enough** for this app: Auth + Firestore + Cloudinary. You do **not** need Blaze unless you add Cloud Functions later.

Skip `firebase deploy` entirely. Do everything in the browser:

### A. Create Firestore

1. Open [Firebase Console → yaaram-80842](https://console.firebase.google.com/project/yaaram-80842/firestore)
2. **Create database** → **Production mode** (we add rules next) → pick a region → **Enable**

### B. Paste security rules (manual)

1. Go to **Firestore → Rules**
2. Replace everything with the contents of `firestore.rules` in this repo (or copy below)
3. Click **Publish**

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function isCoupleMember(coupleId) {
      return isSignedIn() &&
        request.auth.uid in get(/databases/$(database)/documents/couples/$(coupleId)).data.memberIds;
    }

    match /users/{userId} {
      allow read, write: if isSignedIn() && request.auth.uid == userId;
    }

    match /couples/{coupleId} {
      allow read: if isSignedIn() && request.auth.uid in resource.data.memberIds;
      allow create: if isSignedIn();
      allow update: if isSignedIn() &&
        (request.auth.uid in resource.data.memberIds ||
         request.auth.uid in request.resource.data.memberIds);
      allow delete: if false;

      match /memories/{memoryId} {
        allow read, write: if isCoupleMember(coupleId);
      }
    }
  }
}
```

### C. Create composite index (manual)

1. Go to **Firestore → Indexes → Composite**
2. Click **Create index**
3. Set:
   - Collection ID: `memories` (collection group: **off**)
   - Field: `isDeleted` — Ascending
   - Field: `createdAt` — Descending
4. **Create**

Or run the app once — if an index is missing, the debug log shows a link to auto-create it in Console.

### D. Enable Authentication

1. [Authentication → Sign-in method](https://console.firebase.google.com/project/yaaram-80842/authentication/providers)
2. Enable **Email/Password** → Save

### Optional: CLI deploy (works on Spark for rules/indexes only)

If CLI deploy is blocked on your account, use the Console steps above instead.

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## 7. Run the app

```bash
flutter pub get
flutter run
```

## Cloudinary (media uploads)

Create an **unsigned** upload preset named `yaaram_unsigned` in Cloudinary.  
Set values in `.env` (see `.env.example`). Firebase config does **not** go in `.env` — only `flutterfire configure -p yaaram-80842`.

## Troubleshooting login

If `firebase login` fails on Node.js **v24.17.x**, downgrade to **v24.16.0** or **v22.22.x** ([known issue](https://github.com/firebase/firebase-tools/issues/10681)). This is a Node.js bug, not a Flutter issue.
