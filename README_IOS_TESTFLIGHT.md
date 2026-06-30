# Lowkey Maps (iOS) — TestFlight without a Mac

This is a Flutter foundation for the iOS version. It builds and ships to TestFlight
entirely in the cloud via **Codemagic** — you never need to own or touch a Mac.

What's here now: a clean branded starter app (no plugins) so we can prove the
build → sign → TestFlight pipeline first, then port features (map, GPS, roads,
navigation) on top.

- Bundle ID: `app.lowkeymaps.lowkeyMaps`
- Pipeline config: `codemagic.yaml`

---

## One-time setup (≈30–45 min, all from a PC/browser)

### 1. Apple Developer Program — $99/year
- Go to https://developer.apple.com/programs/ and enroll (web + the Apple Developer
  app on an iPhone if it asks to verify). No Mac required.

### 2. Create the app in App Store Connect
- https://appstoreconnect.apple.com → My Apps → **+** → New App.
- Platform: iOS. Name: Lowkey Maps. Bundle ID: create/select `app.lowkeymaps.lowkeyMaps`
  (register it under Certificates, Identifiers & Profiles → Identifiers if it isn't there).
- After it's created, open **App Information** and copy the numeric **Apple ID**
  (a 10-digit number) → put it in `codemagic.yaml` as `APP_STORE_APPLE_ID`.

### 3. Create an App Store Connect API key
- App Store Connect → Users and Access → **Integrations / Keys** → App Store Connect API
  → generate a key with **App Manager** access.
- Download the `.p8` file (one-time download) and note the **Key ID** and **Issuer ID**.

### 4. Codemagic
- Sign up at https://codemagic.io with your GitHub account (free tier is plenty for testing).
- Push this `lowkey_maps_flutter` folder to a Git repo (see "Repo layout" below) and add it as
  an app in Codemagic.
- Teams/Personal Account → **Integrations → App Store Connect** → add the API key
  (.p8 + Key ID + Issuer ID). Give the integration a name and put that name in
  `codemagic.yaml` under `integrations: app_store_connect:` (currently `CodemagicASCKey`).
- Codemagic will auto-detect `codemagic.yaml`. Start a build of the **iOS · TestFlight** workflow.

### 5. First build → TestFlight
- Codemagic spins up a Mac, builds + signs the IPA (signing handled automatically via the
  API key), and uploads to TestFlight.
- In App Store Connect → TestFlight, add yourself/crew as testers (internal testers are
  instant; external testers need a quick Apple beta review). Install via the TestFlight app.

---

## Repo layout

Codemagic auto-detects `codemagic.yaml` at the **repo root**. Easiest option:

- **Recommended:** push the contents of `lowkey_maps_flutter/` as its own GitHub repo
  (so `codemagic.yaml` sits at that repo's root).
- Or keep it inside this monorepo and set the Codemagic project's working directory /
  move `codemagic.yaml` to the repo root and `cd lowkey_maps_flutter` in each script.

---

## Filling in `codemagic.yaml`
- `integrations.app_store_connect`: the name you gave the API-key integration in Codemagic.
- `environment.ios_signing.bundle_identifier`: `app.lowkeymaps.lowkeyMaps` (already set).
- `vars.APP_STORE_APPLE_ID`: the 10-digit Apple ID from step 2.

---

## Porting the real app onto this foundation
The Android app's features map to these Flutter packages when you're ready:
- Map canvas / custom tiles → `CustomPainter` + `flutter_map` (or a custom tile widget)
- GPS → `geolocator`
- Local DB → `drift` or `sqflite`
- Live presence + shared roads → `http`/`dio` against the same Firebase Realtime DB
- Shortest-path routing → port `RoadRouter.kt` to Dart (pure logic, ~1:1)
- CarPlay → `flutter_carplay` (or a small native Swift module via platform channels)

Do this incrementally — each push triggers a fresh TestFlight build automatically.

> Note: CarPlay and the heavy custom map rendering are the hardest parts to port and may
> still need a little native Swift via platform channels. Everything else is straightforward Dart.
