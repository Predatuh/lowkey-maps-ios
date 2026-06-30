# TestFlight Public Beta — approval pack

## Internal vs External (public)
- **Internal testing:** up to 100 testers who are on your App Store Connect team. **No review**, instant. Use this now (works even with the placeholder build).
- **External / Public link:** up to 10,000 testers via a shareable URL. Requires **Beta App Review** (usually < 24–48 h). This is what "public beta list" means.

## ⚠️ The build must be functional
Beta App Review rejects placeholder/demo/non-functional apps (Guideline 2.1 – App Completeness). The current iOS build is just a branded screen → will be rejected for public beta. Ship a build that launches and is genuinely usable (at minimum: shows an imported map + live GPS) before submitting externally.

---

## 1. App-level info (App Store Connect → your app)
- **Name:** Lowkey Maps
- **Subtitle (optional):** Offline jobsite maps & navigation
- **Category:** Navigation (Secondary: Utilities)
- **Age rating:** complete the questionnaire → expected **4+**
- **Privacy Policy URL:** **REQUIRED** (the app uses location). Host a page (Google Sites / GitHub Pages) covering: what's collected (precise location, photos stored on-device), why (show position, navigate), that it works offline, and a contact email for deletion.
- **Support URL:** any reachable page/email.
- **Export compliance:** already handled in Info.plist (`ITSAppUsesNonExemptEncryption=false`) → standard HTTPS only, exempt.

## 2. Required iOS permission strings (Info.plist) for the real build
- `NSLocationWhenInUseUsageDescription` = "Shows your position on the jobsite map and navigates you to on-site equipment."
- `NSCameraUsageDescription` (if photo pins) = "Attach photos to locations on the map."
(Background/Always location is NOT needed — "When In Use" is enough and reviews more easily.)

## 3. TestFlight "Test Information" (External)
- **Feedback email:** your email
- **Beta App Description** (paste):
  > Lowkey Maps is an offline-first field navigation tool for solar and construction jobsites. Import a geo-referenced site map, see your live GPS position on it, drop markers and photos, measure distances, draw the site road network, and navigate to equipment along those roads — all without a cell signal once the map is loaded.
- **What to Test** (paste):
  > • Opening a site map and seeing your GPS position
  > • Pan / zoom / rotate, north lock
  > • Dropping point / line / text / photo markers; measuring distance & area
  > • Navigating to a target and following the route
  > • Offline: turn off mobile data and confirm the map + GPS still work
  > Please report anything confusing, slow, or that crashes.

## 4. Beta App Review Information (the notes the reviewer reads)
- **Sign-in required?** No — core features need no account.
- **Notes** (paste):
  > No login or account required. A sample geo-referenced map is bundled so the app is usable immediately; users can also import their own. Location (When In Use) shows the user's position on the imported map and powers navigation to on-site equipment; it works offline via GPS. There are no ads and no third-party logins. Admin-only tools (drawing the shared road network) are behind a passcode: Settings (gear) → Admin → 081425.
- **Contact:** name, email, phone.

## 5. How to pass review (checklist)
- App launches to a usable screen (no blank/placeholder/"coming soon").
- No crashes; no dead buttons.
- Location prompt appears with the usage string above; app still works if permission is "While Using."
- A sample map is present so the reviewer can see it work without setup.
- Notes explain location use + the offline design.

## 6. Turn on the public link
1. App Store Connect → your app → **TestFlight** → **External Testing** → create a group, e.g. **Public Beta**.
2. Add the (functional) build to the group → fill **Test Information** (sections 3–4) → **Submit for Beta App Review**.
3. After approval, open the group → enable **Public Link** → share the URL. Anyone with the link installs via the TestFlight app.

> Note: the first external build of a version goes through review; minor later builds of the same version usually don't.
