# Yaaram — Our Love Story

A private Flutter app for couples to capture, browse, and cherish shared memories. Store photos, videos, stories, and places in a beautiful timeline — fully offline on the device.

**Package name:** `yaaram`  
**Display name:** Our Love Story  
**Version:** 1.0.0+1  
**Last updated:** July 6, 2026

---

## Table of Contents

1. [What Is It?](#what-is-it)
2. [Why Does It Exist?](#why-does-it-exist)
3. [How Does It Work?](#how-does-it-work)
4. [Features](#features)
5. [Architecture](#architecture)
6. [Project Structure](#project-structure)
7. [Navigation & Routes](#navigation--routes)
8. [Data Layer](#data-layer)
9. [Admin Panel](#admin-panel)
10. [Customization](#customization)
11. [Getting Started](#getting-started)
12. [Running & Building](#running--building)
13. [Testing](#testing)
14. [Dependencies](#dependencies)
15. [Platform Support](#platform-support)
16. [Security Notes](#security-notes)
17. [Troubleshooting](#troubleshooting)

---

## What Is It?

**Yaaram** (meaning *beloved* in Urdu/Hindi) is a couple memories journal built with Flutter. It lets two people (or one person documenting a relationship) save meaningful moments with:

- **Title, story, date, and location** for each memory
- **Photos and videos** attached to memories
- **Timeline, gallery grid, and favorites** views
- **Full-screen media viewer** with pinch-zoom (images) and video playback
- **Offline SQLite cache** with **Firestore sync** when signed in
- **Cloudinary** for photo/video hosting
- **Deep customization** of colors, fonts, and app text labels via a hidden admin panel

The app ships with sample memories on first launch so the UI is never empty.

---

## Why Does It Exist?

Most photo apps are generic galleries. This app is purpose-built for a **love story narrative**:

| Goal | How the app addresses it |
|------|--------------------------|
| Emotional presentation | Romantic gradients, script fonts, heart motifs |
| Story-first | Each memory has title + description, not just a photo |
| Privacy | All data stays on-device in SQLite |
| Personal branding | Custom app title, subtitle, tab names, color palettes |
| Long-term keepsake | Persistent media copied into app storage |

It is a personal project — not published to pub.dev — meant to be installed directly on Android, iOS, or Web.

---

## How Does It Work?

### User journey

```
Splash (3s) → Login (if needed) → Couple setup (if needed) → Home
                ├── Timeline tab    — scrollable memory cards (newest first)
                ├── Gallery tab     — 2-column photo grid
                └── Favorites tab   — starred memories only

FAB (+) → Add Memory → save → Memory Detail

Tap any card → Memory Detail
                ├── View / swipe media
                ├── Favorite / Share
                ├── Edit memory
                └── Delete memory

Long-press app logo → Admin login → Settings & Admin tools
```

### State management

The app uses **[GetX](https://pub.dev/packages/get)** for:

- **Dependency injection** — `MemoryController` and `SettingsController` registered in `main.dart`
- **Reactive UI** — `Obx()` widgets rebuild when data changes
- **Navigation** — named routes via `GetMaterialApp` + `NavigationHelper`

There is no BLoC, Riverpod, or Provider.

### Responsive layout

[`responsive_sizer`](https://pub.dev/packages/responsive_sizer) converts design values to `.w`, `.h`, and `.sp` units so the UI scales across phone sizes.

---

## Features

### Core (user-facing)

| Feature | Status | Details |
|---------|--------|---------|
| Create memory | ✅ | Title, description, location, date, multi-photo/video |
| Edit memory | ✅ | Via card menu or detail screen |
| Delete memory | ✅ | Soft delete with confirmation dialog |
| View memory detail | ✅ | Carousel media, share to clipboard |
| Favorites | ✅ | Toggle from detail screen; dedicated tab |
| Media viewer | ✅ | Full-screen images (pinch zoom) + video (Chewie) |
| Days together counter | ✅ | Shown on splash + home app bar |
| Default sample data | ✅ | 4 memories seeded on first empty DB |

### Admin (hidden)

| Feature | Status | Access |
|---------|--------|--------|
| Color palettes | ✅ | Admin → App Settings → Color Palette |
| Font combinations | ✅ | Admin → App Settings → Font Combination |
| Custom text labels | ✅ | Admin → App Settings → Customized Text |
| Database info | ✅ | Admin → Database Info (dialog) |
| Database admin | ✅ | Table stats, export JSON, clear all |
| Memories admin | ✅ | Raw memory list + restore deleted |
| Change admin password | ✅ | Admin → Change Admin Password |
| Restore deleted memories | ✅ | Memories Admin → restore icon |

**Default admin credentials:** `admin` / `admin123` — change immediately in production.

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                      GetMaterialApp                      │
│              (routes, theme, ResponsiveSizer)            │
└─────────────────────────┬───────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
   Controllers         Views            Utils/Routes
   ───────────         ─────            ────────────
   MemoryController    Screens          NavigationHelper
   SettingsController  Widgets          AppRoutes
                       (reusable UI)    AppTheme
        │                 │
        ▼                 │
   DatabaseService ◄──────┘
   (SQLite singleton)
        │
        ▼
   memories.db + memories_media/ folder
```

### Layer responsibilities

| Layer | Path | Role |
|-------|------|------|
| **Model** | `lib/model/` | `Memory`, `MediaFile` data classes with JSON serialization |
| **Controller** | `lib/controller/` | Business logic, DB access, settings, theme |
| **View** | `lib/view/` | Screens and widgets |
| **Routes** | `lib/routes/` | Named GetX route table |
| **Utils** | `lib/utils/` | Navigation helpers |

---

## Project Structure

```
couple-memories-app/
├── assets/images/logo.svg          # App logo (SVG)
├── lib/
│   ├── main.dart                   # Entry point, DI setup
│   ├── routes/app_routes.dart      # Named route definitions
│   ├── utils/navigation_helper.dart
│   ├── controller/
│   │   ├── memory_controller.dart  # CRUD, favorites, daysTogether
│   │   └── utils/
│   │       ├── admin_auth.dart     # Admin login credentials
│   │       ├── database_admin.dart # Admin DB utilities
│   │       ├── database/database_service.dart
│   │       ├── settings/           # AppSettings + SettingsController
│   │       └── theme/app_theme.dart
│   ├── model/
│   │   ├── memory_model/
│   │   └── media_file_model/
│   └── view/
│       ├── splash_screen/
│       ├── home_screen/
│       ├── add_memory_screen/      # Create + edit mode
│       ├── memory_detail_screen/
│       ├── admin/
│       │   ├── debug_screen.dart           # Admin hub
│       │   ├── database_admin_screen.dart
│       │   └── memories_admin_screen.dart
│       └── widgets/                # 26 reusable widgets
│           ├── admin/              # Admin-only widgets
│           └── media_viewer_screen.dart
├── android/                        # Android (com.yaaram.lovestory)
├── ios/                            # iOS
├── web/                            # Web
└── test/widget_test.dart           # Model unit tests
```

---

## Navigation & Routes

All navigation goes through **`NavigationHelper`** and named routes in **`AppRoutes`**.

| Route | Path | Screen |
|-------|------|--------|
| Splash | `/` | `SplashScreen` |
| Home | `/home` | `HomeScreen` |
| Add/Edit Memory | `/add-memory` | `AddMemoryScreen` (pass `Memory` as argument to edit) |
| Memory Detail | `/memory-detail` | `MemoryDetailScreen` |
| Media Viewer | `/media-viewer` | `MediaViewerScreen` |
| Admin Settings | `/debug` | `DebugScreen` |
| Database Admin | `/database-admin` | `DatabaseAdminScreen` |
| Memories Admin | `/memories-admin` | `MemoriesAdminScreen` |

### Example (programmatic)

```dart
// Create
NavigationHelper.toAddMemory();

// Edit
NavigationHelper.toAddMemory(memoryToEdit: memory);

// View detail
NavigationHelper.toMemoryDetail(memory);

// Admin
NavigationHelper.toDebugScreen();
```

Home tab switching (Timeline / Gallery / Favorites) uses `IndexedStack` — not routes.

---

## Data Layer

### SQLite database

- **File:** `memories.db` (via sqflite)
- **Table:** `memories`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INTEGER PK | Timestamp-based unique ID |
| `date` | TEXT | ISO 8601 memory date |
| `title` | TEXT | Memory title |
| `description` | TEXT | Story text |
| `location` | TEXT | Place name |
| `isFavorite` | INTEGER | 0 or 1 |
| `isDeleted` | INTEGER | 0 = active, 1 = soft deleted |
| `mediaFiles` | TEXT | JSON array of `{path, type, thumbnailPath}` |
| `createdAt` | INTEGER | Creation timestamp |

### Media storage

When a memory is saved, media files are **copied** to:

```
<app_documents>/memories_media/<filename>
```

This ensures photos/videos survive temp picker path cleanup.

### Soft delete vs permanent delete

- **User delete** → `isDeleted = 1` (recoverable in Memories Admin)
- **Admin clear all** → hard `DELETE FROM memories`
- **Admin permanent delete** → `permanentDeleteMemory(id)` API available

### Settings storage

App customization (colors, fonts, text labels) is persisted via **SharedPreferences** through `AppSettings.save()`.

---

## Admin Panel

### How to access

1. On the **home screen**, **long-press the app logo** (top right)
2. Enter admin username and password
3. You land on the **Settings / Admin hub**

### Sections

| Section | What you can do |
|---------|-----------------|
| **App Settings** | Color palette, font combination, customized text |
| **Admin Tools** | Open Database Admin or Memories Admin screens |
| **Change Admin Password** | Set new username/password (stored in SharedPreferences) |
| **Database Info** | Path, size, version (dialog) |

### Database Admin actions

- Print stats to console
- Export full DB as JSON dialog
- Show database file path
- **Clear all memories** (with confirmation)
- View table schema and row counts

### Memories Admin

- Preview all active memories (raw DB rows)
- View deleted memories with **restore** button

---

## Customization

### Color palettes

8 built-in palettes + 1 universal default. Defined in `lib/controller/utils/settings/app_settings.dart`. See also `COLOR_PALETTES_SIMPLIFIED.md` for hex reference.

### Font combinations

Heading + body font pairs using [Google Fonts](https://pub.dev/packages/google_fonts) (Playfair, Lora, Dancing Script, etc.).

### Customizable text

| Setting | Default |
|---------|---------|
| App title | Our Love Story |
| App subtitle | Every moment with you is a treasure |
| Timeline tab | Timeline |
| Gallery tab | Gallery |
| Favorites tab | Favorites |

Changes apply immediately across splash, app bar, and bottom nav.

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.9+ (Dart 3.9+)
- Android Studio / Xcode (for mobile builds)
- Chrome (for web)
- [Firebase CLI](https://firebase.google.com/docs/cli) + [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup) for backend setup

### Install

```bash
git clone <your-repo-url>
cd couple-memories-app
flutter pub get
cp .env.example .env   # Cloudinary only
```

### Firebase (required for auth + sync)

Use the **official** FlutterFire flow — see [FIREBASE_SETUP.md](FIREBASE_SETUP.md):

```bash
firebase login
dart pub global activate flutterfire_cli
flutterfire configure -p yaaram-80842   # project display name: yaaram
# Firestore rules/indexes: set up in Firebase Console (Spark plan — see FIREBASE_SETUP.md)
```

This generates `lib/firebase_options.dart` and `android/app/google-services.json`. Do **not** put Firebase keys in `.env`.

### Run

```bash
# Connected device or emulator
flutter run

# Specific platform
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

---

## Running & Building

### Debug

```bash
flutter run
```

### Release builds

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires Mac + signing)
flutter build ios --release

# Web
flutter build web --release
```

### Android signing

Release builds currently use **debug signing** for convenience. Before publishing:

1. Create a keystore
2. Add `signingConfigs` in `android/app/build.gradle.kts`
3. Set `applicationId` — currently `com.yaaram.lovestory`

---

## Testing

```bash
flutter test
```

Current tests cover `Memory` model serialization and `copyWith`. Widget/integration tests can be expanded with GetX test bindings.

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `get` | State management, DI, navigation |
| `responsive_sizer` | Responsive `.w` / `.h` / `.sp` sizing |
| `sqflite` | Local SQLite database |
| `path_provider` | App documents directory for media |
| `shared_preferences` | Settings persistence |
| `image_picker` | Camera + gallery media selection |
| `google_fonts` | Dynamic font loading |
| `intl` | Date formatting |
| `video_player` + `chewie` | Video thumbnails and playback |
| `photo_view` | Pinch-zoom image viewer |
| `flutter_svg` | SVG logo rendering |
| `firebase_core` / `firebase_auth` / `cloud_firestore` | Auth + cloud sync |
| `flutter_dotenv` | Cloudinary config from `.env` |
| `http` + `cached_network_image` | Cloudinary uploads + remote media |
| `connectivity_plus` | Online/offline detection |

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ | `com.yaaram.lovestory` |
| iOS | ✅ | Bundle ID still `com.example.yaaram` — update in Xcode before App Store |
| Web | ✅ | SQLite via sqflite web; media picker limited |
| macOS / Windows / Linux | ❌ | Not configured |

---

## Security Notes

- **Firebase Auth** — couple accounts; use a strong password.
- **Admin credentials** default to `admin` / `admin123`. Change via admin panel before sharing the device.
- **No encryption** — local database and media are stored in plain files on device.
- **Firestore rules** — deploy `firestore.rules` before production use.
- **Soft delete** — deleted memories remain in DB until restored or cleared by admin.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Videos won't play | Format may be unsupported on device; try H.264 MP4 |
| Images missing after restart | Ensure media was saved (copied to `memories_media/`) |
| Admin login fails | Reset credentials: clear app data or use default `admin`/`admin123` |
| Empty timeline on first launch | Wait for default memories to seed, or add via FAB |
| `flutter run` fails on Android | Run `flutterfire configure` first; check `google-services.json` exists |
| Firebase login fails | Node v24.17.x has a known CLI bug — use Node 24.16 or 22 LTS |

---

## Changelog (July 2026 — full wiring pass)

- ✅ Wired all admin screens (Database Admin, Memories Admin) from admin hub
- ✅ Implemented edit memory flow (create + edit share `AddMemoryScreen`)
- ✅ Wired restore deleted memories in Memories Admin
- ✅ Added delete + edit buttons on memory detail screen
- ✅ Surfaced "days together" on splash and home app bar
- ✅ Added admin credential change UI
- ✅ Added declarative GetX named routes (`AppRoutes`)
- ✅ Removed duplicate/unreachable `SettingsScreen` and orphaned widgets
- ✅ Extracted `MediaViewerScreen` to dedicated file; removed dead `MediaGalleryWidget`
- ✅ Added model unit tests
- ✅ Updated Android application ID to `com.yaaram.lovestory`

---

## License

Private project — not for public distribution unless you add a license.

---

*Built with Flutter and love.*
