$ErrorActionPreference = 'Continue'
Set-Location 'D:\mac\personal\couple-memories-app'

function Commit-Msg([string]$title, [string]$body = '', [bool]$coAuthor = $false) {
  $msg = $title
  if ($body) { $msg = "$title`n`n$body" }
  if ($coAuthor) {
    $msg = "$msg`n`nCo-authored-by: Cursor Agent <cursoragent@cursor.com>"
  }
  $tmp = [System.IO.Path]::GetTempFileName()
  [System.IO.File]::WriteAllText($tmp, $msg)
  git commit -F $tmp | Out-Host
  Remove-Item $tmp -Force
}

function Has-Staged {
  $diff = git diff --cached --name-only
  return [bool]$diff
}

function Stage([string[]]$paths) {
  foreach ($p in $paths) {
    if (Test-Path $p) {
      git add -- $p 2>$null | Out-Null
    } else {
      git add -u -- $p 2>$null | Out-Null
    }
  }
}

Write-Host "Continuing on $(git rev-parse --abbrev-ref HEAD)"

# Finish #4 if still staged
if (Has-Staged) {
  Commit-Msg 'chore: rename Android package and wire Google Services' 'Move applicationId to com.yaaram.lovestory for Firebase client config.'
}

Stage @('android/app/build.gradle.kts','android/gradle.properties','android/gradle/wrapper/gradle-wrapper.properties','android/settings.gradle.kts')
if (Has-Staged) { Commit-Msg 'chore: upgrade Gradle AGP and Built-in Kotlin for release' 'Disable Jetifier and align JVM 21 targets so release APK builds succeed.' }

Stage @('pubspec.yaml','pubspec.lock')
if (Has-Staged) { Commit-Msg 'chore: add Firebase Auth Firestore and Cloudinary app deps' 'Introduce dotenv connectivity google_sign_in and network image caching.' }

Stage @('lib/firebase_options.dart','lib/config/')
if (Has-Staged) { Commit-Msg 'feat: load FlutterFire options and Cloudinary app env' 'Centralize cloud name / unsigned preset loading for media uploads.' $true }

Stage @('lib/model/user_profile_model.dart','lib/model/chat_message_model.dart','lib/model/moments_filter.dart','lib/model/memory_model/memory_comment_model.dart','lib/model/memory_model/memory_model.dart','lib/model/media_file_model/media_file_model.dart','lib/data/')
if (Has-Staged) { Commit-Msg 'feat: add user profile chat and memory interaction models' 'Support onboarding checkpoints notes likes and Cloudinary media fields.' }

Stage @('lib/services/')
if (Has-Staged) { Commit-Msg 'feat: add couple profile chat memory and Cloudinary services' 'Sync memories through Firestore and upload media with unsigned presets.' $true }

Stage @('lib/controller/auth_controller.dart')
if (Has-Staged) { Commit-Msg 'feat: add AuthController with email Google and couple linking' 'Drive session state couple membership and profile refresh after auth.' }

Stage @('lib/controller/profile_onboarding_controller.dart')
if (Has-Staged) { Commit-Msg 'feat: add profile onboarding controller with step checkpoints' 'Persist progress on skip and resume incomplete flow without backstack.' }

Stage @('lib/controller/couple_chat_controller.dart','lib/controller/home_tab_controller.dart','lib/controller/admin_session_controller.dart')
if (Has-Staged) { Commit-Msg 'feat: add chat home-tab and admin-session controllers' 'Stream messages optimistically and gate admin tools behind unlock.' $true }

Stage @('lib/controller/memory_controller.dart','lib/controller/utils/theme/app_theme.dart','lib/controller/utils/admin_auth.dart')
if (Has-Staged) { Commit-Msg 'feat: sync memories to Firestore and prepare Cloudinary uploads' 'Upload media when online and coupled then cache locally for offline.' }

Stage @('lib/routes/','lib/utils/navigation_helper.dart','lib/utils/media_utils.dart','lib/view/widgets/app_screen_shell.dart','lib/view/widgets/auth/')
if (Has-Staged) { Commit-Msg 'feat: add named routes shells and remote/local media helpers' 'Unify light theme screen shell and auth/profile navigation helpers.' }

Stage @('lib/view/auth/')
if (Has-Staged) { Commit-Msg 'feat: add welcome email auth and couple setup screens' 'Let partners generate or join a shared six-character couple code.' $true }

Stage @('lib/view/profile/','lib/view/widgets/profile/')
if (Has-Staged) { Commit-Msg 'feat: add profile onboarding my-profile and chip UI' 'Allow sectional edits while incomplete onboarding blocks pop-back.' }

Stage @('lib/view/home_screen/profile_tab_screen.dart','lib/view/widgets/admin/admin_unlock_dialog.dart')
if (Has-Staged) { Commit-Msg 'feat: replace settings screen with profile hub and admin unlock' 'Merge palette font and logout into the profile tab experience.' }

Stage @('lib/view/home_screen/discover/')
if (Has-Staged) { Commit-Msg 'feat: add Discover timeline stack and memory preview sheet' 'Support like star notes and share-to-chat from discover cards.' $true }

Stage @('lib/view/home_screen/moments/')
if (Has-Staged) { Commit-Msg 'feat: add Moments grid filters and together-moment screen' 'Group shared liked noted memories with owner actions and reminders.' }

Stage @('lib/view/chat/')
if (Has-Staged) { Commit-Msg 'feat: add couple chat UI partner preview and link-required gate' 'Show create/join cards until both partners share a couple code.' }

Stage @('lib/view/home_screen/home_screen.dart','lib/view/widgets/bottom_nav_widget.dart','lib/view/widgets/app_bar_widget.dart','lib/main.dart','lib/view/splash_screen/splash_screen.dart')
if (Has-Staged) { Commit-Msg 'feat: wire Discover Moments Chat Profile tabs and splash routing' 'Boot controllers and route to onboarding couple setup or home.' $true }

Stage @(
  'lib/view/add_memory_screen/add_memory_screen.dart',
  'lib/view/memory_detail_screen/memory_detail_screen.dart',
  'lib/view/widgets/media_viewer_screen.dart',
  'lib/view/widgets/memory_card_media.dart',
  'lib/view/widgets/memory_card_widget.dart',
  'lib/view/widgets/gallery_item_widget.dart',
  'lib/view/widgets/video_thumbnail_widget.dart',
  'lib/view/widgets/media_source_dialog.dart',
  'lib/view/widgets/delete_memory_dialog.dart',
  'lib/view/widgets/save_button_widget.dart',
  'lib/view/widgets/media_gallery_widget.dart',
  'lib/view/widgets/color_circle_widget.dart',
  'lib/view/settings/settings_screen.dart'
)
if (Has-Staged) { Commit-Msg 'feat: update add/detail memory flows for remote media paths' 'Support Cloudinary URLs cached images and draft text from chat.' }

Stage @('lib/view/admin/','lib/view/widgets/admin/','lib/view/widgets/admin_tile_widget.dart')
if (Has-Staged) { Commit-Msg 'refactor: tidy admin tools after settings merge into profile' 'Keep database and memories admin behind the version-tap unlock.' }

Stage @('test/widget_test.dart','README.md')
if (Has-Staged) { Commit-Msg 'docs: refresh README and fix widget smoke test boot path' 'Document cloud couple features and keep analyzer-friendly tests.' $true }

# leftover including scripts
git add -A
git restore --staged .env 2>$null | Out-Null
if (Has-Staged) { Commit-Msg 'chore: finalize remaining cloud couple app integration polish' 'Land leftover theme navigation packaging and commit helper script.' }

Write-Host '==== COMMITS AHEAD OF MAIN ===='
git rev-list --count origin/main..HEAD
git log --oneline origin/main..HEAD
Write-Host '==== STATUS ===='
git status --short
