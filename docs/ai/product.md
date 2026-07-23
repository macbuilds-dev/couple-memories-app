# Product

## What

Yaaram is a private Flutter app for couples to capture shared memories (photos/videos/stories), browse Discover/Moments, chat, and sync theme/settings between partners via Firestore.

## Users

Two linked partners (couple code). Optional single-user/offline SQLite mode before couple link.

## Core flows

1. Splash → auth (email/Google) → profile onboarding → couple create/join → Home
2. Home tabs: Discover | Moments | Chat | Profile
3. Add memory → media (local + Cloudinary when online) → partner sees via Firestore stream
4. Chat text (+ memory share) → partner stream + alert/FCM when away
5. Profile: palette + light/dark sync on `couples/{id}.appSettings`
