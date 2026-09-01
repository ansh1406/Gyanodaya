# AI Agent Implementation Specification
## Flutter QR-Based Video Application — V1.0

## 1. Purpose

Build a Flutter mobile application whose primary function is to scan QR codes and immediately play the video associated with each QR code.

The application also supports local user signup, login, logout, and profile management.

Keep the implementation simple, modular, readable, and easy to extend. Do not introduce backend infrastructure or unnecessary architectural complexity.

## 2. Fixed Requirements

### QR and Video
- QR scanning works without authentication.
- A QR scan produces a string.
- A static `Map<String, String>` maps QR output strings to video IDs.
- Video IDs are fixed during development.
- All videos are bundled with the Flutter application as Flutter assets.
- Videos are not downloaded from a server and do not require internet connectivity.
- A valid QR scan immediately opens the corresponding Video Player screen.
- An invalid or unknown QR value shows a clear error and does not open the player.
- When a video finishes, remain on the Video Player screen.

### Authentication
- Authentication is local for V1.
- Signup uses a mobile number and OTP verification.
- OTP is currently provided by a mock implementation running inside the application.
- After successful OTP verification, the user creates a password.
- Subsequent login uses mobile number + password.
- User/authentication data is stored locally.
- No database service or remote authentication provider is required for V1.
- Forgot-password functionality is out of scope.
- Passwords must not be stored as plain text; use an appropriate secure password-hashing mechanism.

### Profile
- Profile data is stored locally.
- Logged-in users can view their profile.
- Supported profile information can be updated.

### Home
- Home is accessible whether or not the user is authenticated.
- Home contains an application title bar, hamburger menu, and prominent Scan QR button.
- The main Home content remains minimal.

### Side Menu
Logged out:
- Home
- Login
- Signup

Logged in:
- Home
- Profile
- Logout

## 3. Architecture

Use a lightweight layered architecture:

```text
Screens
   ↓
Services
   ↓
Local Data / Assets / External Implementations
```

Screens must not directly depend on storage implementation details, QR package APIs, video asset paths, or future authentication providers.

Do not introduce full Clean Architecture, excessive repositories, unnecessary abstractions, or complex state-management structures without a concrete requirement.

## 4. Project Structure

Use this structure as the default:

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── models/
│   ├── user.dart
│   └── video.dart
├── screens/
│   ├── splash/splash_screen.dart
│   ├── home/home_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── otp_screen.dart
│   │   └── create_password_screen.dart
│   ├── scanner/qr_scanner_screen.dart
│   ├── video/video_player_screen.dart
│   └── profile/profile_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── otp_service.dart
│   ├── local_storage_service.dart
│   ├── qr_scanning_service.dart
│   └── video_service.dart
├── data/
│   ├── qr_video_map.dart
│   └── video_assets.dart
├── widgets/
│   ├── app_drawer.dart
│   ├── app_button.dart
│   └── ...
└── utils/
    ├── constants.dart
    └── validators.dart
```

Agents may adjust the structure only when there is a clear implementation reason while preserving separation of screens, services, models, and static data.

## 5. Models

### User
Create a `User` model containing only information actually required by the application. Do not add speculative fields.

### Video
Create a `Video` model containing at least:
- `id`
- `assetPath`

Optional metadata such as title may be added if required by the UI.

## 6. Video Assets

Store videos predictably:

```text
assets/
└── videos/
    ├── video_001.mp4
    ├── video_002.mp4
    └── ...
```

Register them in `pubspec.yaml`.

Videos are read-only application assets. Do not implement downloading, caching, remote streaming, or offline-download management in V1.

## 7. QR-to-Video Mapping

Maintain the mapping as static application data:

```dart
const Map<String, String> qrVideoMap = {
  'qr_string_001': 'video_001',
  'qr_string_002': 'video_002',
  'qr_string_003': 'video_003',
};
```

The mapping must not be embedded inside a screen.

Flow:

```text
QR Scanner
    ↓
QR String
    ↓
qrVideoMap
    ↓
Video ID
    ↓
VideoService
    ↓
Bundled Video Asset
    ↓
Video Player
```

If the QR string is not found:
- Do not navigate to the player.
- Show a user-friendly error.
- Allow another scan.

## 8. QR Scanning Service

The service is responsible only for camera access, QR detection, and returning the detected string.

It must not:
- Know about video IDs
- Contain the QR-to-video map
- Navigate between screens
- Contain UI logic

Stop or ignore further scan events after a successful detection to prevent duplicate navigation.

Handle camera permission denial gracefully.

## 9. Video Service

The Video Service resolves a video ID into bundled asset information.

The Video Player must not hard-code asset paths. It should receive a video ID and obtain the asset through the service.

This separation should make future migration from bundled videos to remote videos possible without rewriting the player UI.

## 10. Video Player

The player receives a video ID through navigation.

It must support:
- Loading state
- Play/pause
- Seeking/progress
- Playback errors
- Proper controller/resource disposal

When playback finishes, remain on the Video Player screen.

## 11. Authentication Services

Separate authentication and OTP responsibilities.

### AuthService
Responsible for:
- Account creation
- Login
- Logout
- Current authentication state
- Current user

### OtpService
Responsible for:
- Requesting/sending an OTP
- Verifying an OTP

Current implementation:

```text
OtpService
    ↓
MockOtpService
```

Future implementation may be:

```text
OtpService
    ↓
RealOtpService
    ↓
External OTP provider
```

The UI must not know whether the OTP service is mocked or real.

## 12. Mock OTP

Keep all mock OTP behavior inside the mock service.

The Signup screen should call the OTP service and react to success/failure. Do not place hard-coded OTP verification logic throughout the UI.

## 13. Signup Flow

Implement exactly:

```text
Signup
   ↓
Enter mobile number
   ↓
Request OTP
   ↓
OTP Screen
   ↓
Verify OTP
   ↓
Create Password Screen
   ↓
Create local account
   ↓
Store user locally
   ↓
Authenticated
   ↓
Home
```

Validate phone number, OTP, and password at the appropriate stages.

## 14. Login Flow

Implement:

```text
Login
   ↓
Mobile number + password
   ↓
AuthService
   ↓
Local credentials
   ↓
Successful authentication
   ↓
Home
```

Invalid credentials must produce a clear error.

Forgot-password is not part of V1.

## 15. Local Storage

There is no database service.

`LocalStorageService` handles local user, profile, and authentication data.

Conceptually it should support:

```text
saveUser()
getUser()
updateUser()
deleteUser()
saveLoginState()
getLoginState()
clearLoginState()
```

The storage technology may be selected during implementation.

Do not use local storage to manage video files.

## 16. Password Security

Never store passwords in plaintext.

Use a suitable password hashing and verification mechanism.

Never:
- Log passwords
- Store raw passwords in debug output
- Hard-code real credentials
- Log OTPs unnecessarily

## 17. Authentication Persistence

On startup:

```text
Splash
   ↓
Read local authentication state
   ↓
Set current auth state
   ↓
Home
```

Both authenticated and unauthenticated users go to Home.

Authentication only affects drawer options and profile/logout availability.

QR scanning remains available in both states.

## 18. Profile

Profile must:
- Load user information through `LocalStorageService`
- Display the information
- Allow supported fields to be edited
- Save changes through `LocalStorageService`

The UI must not directly access the underlying storage package.

## 19. Splash

Responsibilities:
- Display splash UI
- Initialize required application state
- Load local authentication state
- Navigate to Home

Do not place business logic directly in the splash UI.

## 20. Home

Home contains:

```text
┌───────────────────────────────┐
│ ☰          APP NAME           │
├───────────────────────────────┤
│                               │
│         [ SCAN QR ]           │
│                               │
└───────────────────────────────┘
```

The Scan QR button:
- Is always visible
- Requires no authentication
- Opens the QR Scanner

## 21. Drawer

Logged out:
```text
Home
Login
Signup
```

Logged in:
```text
Home
Profile
Logout
```

Logout must clear the authenticated session, update authentication state, and return/show Home in the logged-out state.

## 22. Navigation

Centralize route definitions for:

```text
Splash
Home
Login
Signup
OTP
Create Password
QR Scanner
Video Player
Profile
```

Do not scatter raw route strings throughout the application.

Pass video IDs explicitly when opening the Video Player.

## 23. Error Handling

Handle expected failures without crashing.

### QR
- Camera permission denied
- QR not detected
- Invalid QR
- Unknown QR mapping

### Authentication
- Invalid phone number
- OTP request failure
- Incorrect OTP
- Password validation failure
- Invalid login credentials

### Storage
- Failed read
- Failed write
- Missing user data

### Video
- Missing asset
- Player initialization failure
- Playback failure

Show simple, user-friendly messages rather than raw exceptions.

## 24. State Management

Use the simplest state-management approach that comfortably handles:
- Authentication state
- Current user/profile state
- Loading/error states

Do not introduce complex state-management architecture without need.

QR scan state can remain local to the scanner flow.

## 25. Implementation Order

### Phase 1 — Foundation
- Create Flutter project
- Set up folders
- Configure theme
- Configure routes
- Configure assets

### Phase 2 — Home
- Home screen
- App bar
- Drawer
- Scan QR button

### Phase 3 — QR
- QR scanning service
- Camera permissions
- QR string extraction
- Static QR-to-video map
- Invalid QR handling

### Phase 4 — Video
- Video model
- Video service
- Bundled video assets
- Video player
- Player states/errors
- Controller disposal

Core milestone:

```text
Scan QR → Resolve Video → Play Video
```

### Phase 5 — Local Storage
- User model
- LocalStorageService
- Storage implementation
- User data persistence
- Login-state persistence

### Phase 6 — Authentication
- AuthService
- OtpService
- MockOtpService
- Signup
- Login
- Logout
- Authentication state

### Phase 7 — Profile
- Profile screen
- Load local data
- Edit/save profile

### Phase 8 — Hardening
- Error handling
- Permissions
- Edge cases
- UI consistency
- Android testing

## 26. Acceptance Criteria

### QR
- [ ] QR scanning works without login.
- [ ] QR output is read as a string.
- [ ] Valid QR resolves to the correct video ID.
- [ ] Correct bundled video opens immediately.
- [ ] Invalid QR shows an error.
- [ ] Duplicate scan events do not cause duplicate navigation.

### Video
- [ ] All configured videos can be played.
- [ ] Videos work without internet.
- [ ] Basic playback controls work.
- [ ] Video remains on screen after completion.
- [ ] Player resources are properly released.

### Signup
- [ ] User can enter a phone number.
- [ ] Mock OTP can be requested.
- [ ] OTP can be verified.
- [ ] User can create a password.
- [ ] User data is stored locally.
- [ ] User becomes authenticated after signup.

### Login
- [ ] Correct credentials authenticate successfully.
- [ ] Incorrect credentials are rejected.
- [ ] Login state persists across application restart.

### Logout
- [ ] Logout clears the authenticated session.
- [ ] Drawer changes to logged-out options.

### Profile
- [ ] Profile loads from local storage.
- [ ] Supported profile information can be edited.
- [ ] Changes persist after application restart.

### General
- [ ] Expected user errors do not crash the app.
- [ ] Camera permission denial is handled.
- [ ] UI works on supported Android and iOS devices.
- [ ] QR/video functionality has no unnecessary network dependency.

## 27. Non-Negotiable Constraints

Agents MUST:
1. Not add a database.
2. Not add remote video streaming.
3. Not add video downloading or caching.
4. Not require authentication for QR scanning.
5. Not put QR-to-video mapping inside UI screens.
6. Not put mock OTP logic inside UI screens.
7. Not store passwords in plaintext.
8. Not hard-code video paths throughout the UI.
9. Not implement forgot-password.
10. Not introduce unnecessary architectural layers.
11. Keep provider-specific implementations replaceable.
12. Handle asynchronous operations with loading, success, and error states.
13. Dispose camera/video resources correctly.
14. Avoid adding unspecified features without explicit approval.
15. Prefer readable, maintainable Dart/Flutter code over clever abstractions.

## 28. Future Extension Points

The architecture should permit:

```text
MockOtpService        → Real OTP provider
Local authentication  → Remote authentication
Local profile data    → Remote database/API
Bundled videos        → Remote video delivery
Static QR map         → Remote QR/video mapping
```

These are future possibilities only and must not be implemented in V1 unless explicitly requested.

## 29. Final Core Flow

```text
HOME
  ↓
Scan QR
  ↓
QR Scanner
  ↓
QR String
  ↓
QR → Video Map
  ↓
Video ID
  ↓
Video Service
  ↓
Bundled Asset
  ↓
Video Player
  ↓
Remain on Screen
```

Authentication is independent:

```text
Signup
  ↓
Phone
  ↓
Mock OTP
  ↓
Create Password
  ↓
Local User Data
  ↓
Authenticated
```

and:

```text
Login
  ↓
Phone + Password
  ↓
Local Verification
  ↓
Authenticated
  ↓
Home
```

This document is the source of truth for implementation unless requirements are explicitly changed.
