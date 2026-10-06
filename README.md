# Learning Dashboard — Mobile Architecture & Implementation

A robust, offline-capable mobile application built in Flutter using **Clean Architecture** with **Cubit (`flutter_bloc`)** state management, repository pattern with offline-first caching, interactive lesson progress tracking, and unit/bloc test coverage.

---

### 📱 Demo & Artifacts
- 🎥 **Screen Recording**: [Watch Video Walkthrough (Google Drive)](https://drive.google.com/file/d/1WiapDD_5hRFNCyWeEx2KcP1dsWjIYnu_/view?usp=sharing)
- 📦 **Release APK**: [Download app-release.apk (Google Drive)](https://drive.google.com/file/d/1cpxH1btD3VwIiX3zMlqoXVm-qklm2dZb/view?usp=sharing) *(Local build: `build/app/outputs/flutter-apk/app-release.apk`)*

---

### 1. Architecture
**Why Clean Architecture + Cubit?**
- **Strict Separation of Concerns**: Structured according to Uncle Bob's Clean Architecture into three decoupled layers:
  - **Domain**: Pure Dart business logic, entities (`Course`, `Lesson`, `User`), repository contracts, and isolated **Use Cases** (`LoginUseCase`, `GetCoursesUseCase`, `GetCourseDetailsUseCase`, `ToggleLessonCompletionUseCase`, `LogoutUseCase`). This layer has zero dependencies on Flutter UI, third-party state managers, or platform plugins.
  - **Data**: Data transfer models with serialization (`CourseModel`, `LessonModel`), data sources (Remote mock API & Local persistent storage), and `CourseRepositoryImpl` implementing network-first with cache-fallback resilience.
  - **Presentation**: **Cubit** state managers (`LoginCubit`, `CourseDashboardCubit`, `CourseDetailsCubit`) emitting immutable, equatable states (`Initial`, `Loading`, `Loaded`, `Empty`, `Error`) consumed by declarative UI widgets using `BlocBuilder`, `BlocConsumer`, and `BlocProvider`.
- **Predictable & Unidirectional Data Flow (UDF)**:
  `UI Event / Action → Cubit Function → UseCase → Repository → Cubit emits State → UI Rebuilds`
- **Testability**: Use cases and Cubits are tested in isolation using `bloc_test`, validating exact state transitions deterministically without UI rendering.

---

### 2. Offline Support
**How offline data is stored and loaded:**
- **Real Network Detection**: Offline mode is driven automatically by real device network connectivity via `NetworkInfo` (wrapping `connectivity_plus`). When the device loses internet access, the app detects it in real time via an event stream.
- **Local Persistence**: Course and lesson data are persisted locally via `CourseLocalDataSource` (backed by persistent disk storage / `SharedPreferences`).
- **Network-First with Graceful Cache Fallback**:
  - When online, the app fetches fresh data from the remote source, merges any local user progress, and updates disk cache.
  - When network drops or the device goes offline, `CourseRepository` seamlessly loads and serves previously cached courses, displaying an offline banner.
  - If the device reconnects to the internet, `CourseDashboardCubit` listens to connectivity changes and automatically triggers a fresh sync.
- **Lesson Progress Sync**: Completing a lesson triggers `ToggleLessonCompletionUseCase`, which recalculates progress (`(completed / total) * 100`), updates the local database, and updates the dashboard screen upon back-navigation.

---

### 3. Security
**Authentication Token Storage:**
- **Active Implementation**: Tokens and user credentials are encrypted and stored via [`AuthLocalDataSourceImpl`](file:///Users/akshay/Documents/projects/new_project/lib/data/datasources/auth_local_datasource.dart) using **`flutter_secure_storage`**:
  - **iOS / macOS**: Backed by **Apple Keychain** using `kSecClassGenericPassword` with `KeychainAccessibility.first_unlock_this_device`.
  - **Android**: Backed by the **Android KeyStore** using AES-GCM with RSA OAEP key wrapping.
- **In-Transit Security**: Enforce HTTPS with TLS 1.3 and **SSL/TLS Certificate Pinning** to eliminate Man-in-the-Middle (MitM) attacks.
- **Lifecycle**: Keep tokens exclusively in secure storage or memory; use an HTTP interceptor for automatic token refresh via refresh tokens.

---

### 4. Scale (Mobile App Improvements for 1M Users & Hundreds of Courses)

To scale the **mobile client application** reliably for 1,000,000+ active users and hundreds of courses without performance bottlenecks or memory crashes:

1. **Relational Database with Indexed Queries & Lazy Cursor Pagination (Drift / SQLite)**
   - *Current State*: Course and lesson models are serialized into `SharedPreferences` as raw JSON strings.
   - *Improvement*: Migrate to an indexed SQLite database using **Drift** or **sqflite** with relational tables (`courses`, `lessons`, `progress`). Implement cursor-based pagination (e.g., 20 courses per batch) in `ListView.builder` to keep resident memory footprint (RAM) low and constant regardless of catalog size.

2. **Offload Heavy JSON Parsing & Calculations to Background Isolates (`Isolate.run` / `compute`)**
   - *Current State*: Deserializing and filtering large course structures runs synchronously on the main Dart UI isolate.
   - *Improvement*: Offload large JSON payload parsing, model mapping, and complex progress metrics calculation to a worker Dart isolate using `Isolate.run()` or `compute()`. This eliminates main thread blocking and preserves buttery smooth 60/120 fps scrolling and animations.

3. **Persistent Background Sync Queue via Native WorkManager / BackgroundTasks**
   - *Current State*: Offline progress sync runs when the app is active in the foreground and receives connectivity stream events.
   - *Improvement*: Store pending mutations in an atomic local SQLite queue table and execute background synchronization using `workmanager` (Android `WorkManager`) and `BGAppRefreshTask` (iOS `BackgroundTasks`). Offline lesson progress will automatically sync even if the user force-closes the app.

4. **Multi-Tier Thumbnail Caching with Memory Pressure Eviction (`cached_network_image`)**
   - *Current State*: Basic network image loading.
   - *Improvement*: Integrate `cached_network_image` with dual-tier (in-memory LRU + persistent disk) cache boundaries and downsampling (`cacheWidth` / `cacheHeight`). Evict in-memory image textures on system `didHaveMemoryPressure` callbacks to prevent Out-Of-Memory (OOM) crashes across diverse Android & iOS hardware.

5. **Client-Side APM, Memory Profiling & Offline Telemetry Buffering**
   - *Current State*: Console error output.
   - *Improvement*: Integrate Firebase Crashlytics & Performance Monitoring / Sentry to track client-side Time-to-Interactive (TTI), slow frames (jank metrics), network timeouts, and buffer error diagnostics locally to upload when back online.

---

### 5. Second Platform (Running on iOS using Flutter)

Since the app was initially targeted for Android, the following configurations and steps are required to run and deploy seamlessly on **iOS** using Flutter:

#### 1. Xcode & iOS Project Configuration
- **Minimum Deployment Target**: Update `ios/Podfile` to uncomment and set `platform :ios, '13.0'` (or higher) to meet plugin baseline requirements (`flutter_secure_storage` and `connectivity_plus`).
- **CocoaPods Dependency Resolution**: Run CocoaPods pod installation to link native iOS pods:
  ```bash
  cd ios && pod install
  ```
- **Signing & Bundle Identifier**: Open `ios/Runner.xcworkspace` in Xcode, configure a valid **Apple Developer Team**, signing certificate, and set a unique Bundle Identifier (`com.example.learningDashboard`).

#### 2. Native Security & Keychain Storage
- **Apple Keychain Access**: On Android, secure storage uses KeyStore; on iOS, it maps to Apple Keychain.
- **Keychain Configuration**: In [`AuthLocalDataSourceImpl`](file:///Users/akshay/Documents/projects/new_project/lib/data/datasources/auth_local_datasource.dart), pass `IOSOptions`:
  ```dart
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  )
  ```
  *(Already configured in the codebase to ensure encrypted tokens persist across device reboots).*
- **Keychain Sharing (Optional)**: If sharing authentication tokens with iOS App Extensions or Watch apps, enable the **Keychain Sharing** entitlement in Xcode.

#### 3. Info.plist & Privacy Permissions
- **App Transport Security (ATS)**: In `ios/Runner/Info.plist`, ensure HTTPS compliance (`NSAppTransportSecurity`) for network calls.
- **Background Modes (Optional)**: If implementing background sync queues on iOS, enable `Background Fetch` and `Background Processing` with `BGAppRefreshTask`.

#### 4. UI/UX Platform Adaptations
- **Screen Insets**: Ensure screens utilize `SafeArea` to avoid overlaps with the iPhone Notch, Dynamic Island, and Home Indicator bar.
- **Cupertino Gestures**: Configure `CupertinoPageTransitionsBuilder` for native iOS interactive swipe-to-go-back gesture transitions.
- **Keyboard Dismissal**: Wrap input forms in `GestureDetector(onTap: () => FocusScope.of(context).unfocus())` for native iOS tap-to-dismiss keyboard behavior.

#### 5. Build & Distribution Commands
```bash
# Run on iOS Simulator
flutter run -d "iPhone 16"

# Run on connected iOS device
flutter run -d <ios-device-id>

# Build release archive for TestFlight / App Store
flutter build ipa --export-method app-store
```

---

### How to Run
```bash
# 1. Install dependencies
flutter pub get

# 2. Run static analysis
flutter analyze

# 3. Run all unit and bloc tests
flutter test

# 4. Run application
flutter run -d macos  # or chrome / android / ios
```
