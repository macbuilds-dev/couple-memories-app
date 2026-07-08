# PowerShell commit orchestrator for couple-memories-app
$ErrorActionPreference = 'Stop'
Set-Location 'D:\mac\personal\couple-memories-app'

function Commit-Msg([string]$title, [string]$body = '', [bool]$coAuthor = $false) {
  $msg = $title
  if ($body) { $msg = "$title`n`n$body" }
  if ($coAuthor) {
    $msg = "$msg`n`nCo-authored-by: Cursor Agent <cursoragent@cursor.com>"
  }
  # Use -F with temp file for reliable multiline commits on Windows
  $tmp = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllText($tmp, $msg)
  git commit -F $tmp
  Remove-Item $tmp -Force
}

function Try-Add([string[]]$paths) {
  foreach ($p in $paths) {
    if (Test-Path $p) {
      git add -- $p 2>$null | Out-Null
    } else {
      # Stage deletion if it was a tracked path
      git add -u -- $p 2>$null | Out-Null
    }
  }
}

# Abort if already committed partially
$branch = git rev-parse --abbrev-ref HEAD
if ($branch -eq 'main') {
  git checkout -b feat/cloud-couple-memories-v1
}

Write-Host "On branch: $(git rev-parse --abbrev-ref HEAD)"

# ---- COMMIT PLAN ----
# 1 docs/ignore
Try-Add @('.gitignore')
if (git diff --cached --quiet) { Write-Host 'skip 1' } else {
  Commit-Msg 'chore: ignore local .env secrets for Cloudinary and keys' 'Keep example env files tracked while preventing credential leaks.'
}

# 2 docs
Try-Add @('.env.example', 'FIREBASE_SETUP.md')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'docs: add Firebase setup guide and Cloudinary env example' 'Document Auth, Firestore, and unsigned upload bootstrap steps.' $true
}

# 3 firebase rules
Try-Add @('.firebaserc', 'firebase.json', 'firestore.rules', 'firestore.indexes.json')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'chore: add Firebase config and Firestore security rules' 'Encode couple membership RBAC for profiles, memories, and chat.'
}

# 4 android package
Try-Add @(
  'android/app/google-services.json',
  'google-services.json',
  'android/app/src/main/AndroidManifest.xml',
  'android/app/src/main/kotlin/com/yaaram/',
  'android/app/src/main/kotlin/com/example/yaaram/'
)
git add -u -- 'android/app/src/main/kotlin/com/example/yaaram' 2>$null
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'chore: rename Android package and wire Google Services' 'Move applicationId to com.yaaram.lovestory for Firebase client config.'
}

# 5 gradle
Try-Add @('android/app/build.gradle.kts','android/gradle.properties','android/gradle/wrapper/gradle-wrapper.properties','android/settings.gradle.kts')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'chore: upgrade Gradle AGP and Built-in Kotlin for release' 'Disable Jetifier and align JVM 21 targets so release APK builds succeed.'
}

# 6 pubspec deps
Try-Add @('pubspec.yaml','pubspec.lock')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'chore: add Firebase Auth Firestore and Cloudinary app deps' 'Introduce dotenv connectivity google_sign_in and network image caching.'
}

# 7 firebase options + env
Try-Add @('lib/firebase_options.dart','lib/config/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: load FlutterFire options and Cloudinary app env' 'Centralize cloud name / unsigned preset loading for media uploads.' $true
}

# 8 models
Try-Add @('lib/model/user_profile_model.dart','lib/model/chat_message_model.dart','lib/model/moments_filter.dart','lib/model/memory_model/memory_comment_model.dart','lib/model/memory_model/memory_model.dart','lib/model/media_file_model/media_file_model.dart','lib/data/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add user profile chat and memory interaction models' 'Support onboarding checkpoints notes likes and Cloudinary media fields.'
}

# 9 services
Try-Add @('lib/services/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add couple profile chat memory and Cloudinary services' 'Sync memories through Firestore and upload media with unsigned presets.' $true
}

# 10 auth + couple controller
Try-Add @('lib/controller/auth_controller.dart')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add AuthController with email Google and couple linking' 'Drive session state couple membership and profile refresh after auth.'
}

# 11 profile onboarding controller
Try-Add @('lib/controller/profile_onboarding_controller.dart')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add profile onboarding controller with step checkpoints' 'Persist progress on skip and resume incomplete flow without backstack.'
}

# 12 chat controller
Try-Add @('lib/controller/couple_chat_controller.dart','lib/controller/home_tab_controller.dart','lib/controller/admin_session_controller.dart')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add chat home-tab and admin-session controllers' 'Stream messages optimistically and gate admin tools behind unlock.' $true
}

# 13 memory controller update
Try-Add @('lib/controller/memory_controller.dart','lib/controller/utils/theme/app_theme.dart','lib/controller/utils/admin_auth.dart')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: sync memories to Firestore and prepare Cloudinary uploads' 'Upload media when online and coupled then cache locally for offline.'
}

# 14 routes + navigation + media utils
Try-Add @('lib/routes/','lib/utils/navigation_helper.dart','lib/utils/media_utils.dart','lib/view/widgets/app_screen_shell.dart','lib/view/widgets/auth/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add named routes shells and remote/local media helpers' 'Unify light theme screen shell and auth/profile navigation helpers.'
}

# 15 auth screens
Try-Add @('lib/view/auth/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add welcome email auth and couple setup screens' 'Let partners generate or join a shared six-character couple code.' $true
}

# 16 profile onboarding + my profile
Try-Add @('lib/view/profile/','lib/view/widgets/profile/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add profile onboarding my-profile and chip UI' 'Allow sectional edits while incomplete onboarding blocks pop-back.'
}

# 17 profile hub
Try-Add @('lib/view/home_screen/profile_tab_screen.dart','lib/view/widgets/admin/admin_unlock_dialog.dart')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: replace settings screen with profile hub and admin unlock' 'Merge palette font and logout into the profile tab experience.'
}

# 18 discover
Try-Add @('lib/view/home_screen/discover/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add Discover timeline stack and memory preview sheet' 'Support like star notes and share-to-chat from discover cards.' $true
}

# 19 moments
Try-Add @('lib/view/home_screen/moments/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add Moments grid filters and together-moment screen' 'Group shared liked noted memories with owner actions and reminders.'
}

# 20 chat UI
Try-Add @('lib/view/chat/')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: add couple chat UI partner preview and link-required gate' 'Show create/join cards until both partners share a couple code.'
}

# 21 home + nav
Try-Add @('lib/view/home_screen/home_screen.dart','lib/view/widgets/bottom_nav_widget.dart','lib/view/widgets/app_bar_widget.dart','lib/main.dart','lib/view/splash_screen/splash_screen.dart')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: wire Discover Moments Chat Profile tabs and splash routing' 'Boot controllers and route to onboarding couple setup or home.' $true
}

# 22 memory detail + add memory + widgets updates
Try-Add @(
  'lib/view/add_memory_screen/add_memory_screen.dart',
  'lib/view/memory_detail_screen/memory_detail_screen.dart',
  'lib/view/widgets/media_viewer_screen.dart',
  'lib/view/widgets/memory_card_media.dart',
  'lib/view/widgets/memory_card_widget.dart',
  'lib/view/widgets/gallery_item_widget.dart',
  'lib/view/widgets/video_thumbnail_widget.dart',
  'lib/view/widgets/media_source_dialog.dart',
  'lib/view/widgets/delete_memory_dialog.dart',
  'lib/view/widgets/save_button_widget.dart'
)
# deletions of old widgets
git add -u -- 'lib/view/widgets/media_gallery_widget.dart' 'lib/view/widgets/color_circle_widget.dart' 'lib/view/settings/settings_screen.dart' 2>$null
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'feat: update add/detail memory flows for remote media paths' 'Support Cloudinary URLs cached images and draft text from chat.'
}

# 23 admin widgets cleanup
Try-Add @(
  'lib/view/admin/',
  'lib/view/widgets/admin/'
)
git add -u -- 'lib/view/widgets/admin/' 'lib/view/widgets/admin_tile_widget.dart' 2>$null
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'refactor: tidy admin tools after settings merge into profile' 'Keep database and memories admin behind the version-tap unlock.'
}

# 24 tests + readme
Try-Add @('test/widget_test.dart','README.md')
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'docs: refresh README and fix widget smoke test boot path' 'Document cloud couple features and keep analyzer-friendly tests.' $true
}

# 25 remaining everything else
git add -A
# ensure .env not staged
git restore --staged .env 2>$null
if (-not (git diff --cached --quiet)) {
  Commit-Msg 'chore: finalize remaining cloud couple app integration polish' 'Land leftover theme navigation and packaging adjustments.'
}

Write-Host '---- COMMIT COUNT ----'
git rev-list --count origin/main..HEAD
git log --oneline origin/main..HEAD
