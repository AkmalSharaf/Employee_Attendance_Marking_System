# Complete Flutter Setup Guide for Windows

This guide will walk you through setting up Flutter and running this Employee Attendance App from scratch.

> **Note:** The Android build files in this project have already been pre-configured for Firebase. You only need to add the `google-services.json` file and update `firebase_options.dart`.

## Prerequisites Checklist

Before starting, make sure you have:
- [ ] Windows 10 or later
- [ ] At least 20GB free disk space
- [ ] A Google account (for Firebase)

---

## Step 1: Install Git for Windows

Git is required to work with Flutter and version control.

1. Download Git from: https://git-scm.com/download/win
2. Run the installer with default settings
3. During installation, choose "Use Git from Windows PowerShell"
4. Complete the installation

---

## Step 2: Install Flutter SDK

### Method A: Using Git (Recommended)

1. Create a folder where Flutter will be installed (e.g., `C:\flutter`)
2. Open Command Prompt (Win + R, type `cmd`, press Enter)
3. Run these commands:

```cmd
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```

### Method B: Download ZIP

1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Click "Download the Flutter SDK" 
3. Extract the ZIP to `C:\flutter`

---

## Step 3: Add Flutter to PATH

1. Press Windows key, search "Environment Variables"
2. Click "Edit the system environment variables"
3. Click "Environment Variables" button
4. Under "System variables", find "Path", double-click to edit
5. Click "New" and add: `C:\flutter\bin`
6. Click "OK" to save

---

## Step 4: Verify Flutter Installation

1. Open a new Command Prompt
2. Run:

```cmd
flutter --version
```

You should see something like:
```
Flutter 3.x.x
Dart 3.x.x
```

3. Run:

```cmd
flutter doctor
```

This checks your setup. Don't worry if it shows some warnings - we'll fix them.

---

## Step 5: Install Android Studio

Flutter apps need Android SDK to build Android apps.

1. Download Android Studio from: https://developer.android.com/studio
2. Run the installer with default settings
3. After installation, open Android Studio
4. Go to "More Actions" > "SDK Manager"
5. Under "SDK Platforms", check the latest Android version
6. Under "SDK Tools", check:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
7. Click "Apply" to download

---

## Step 6: Accept Android Licenses

Open Command Prompt and run:

```cmd
flutter doctor --android-licenses
```

Press `y` and Enter for each license prompt.

---

## Step 7: Configure Firebase

### 7.1 Create Firebase Project

1. Go to: https://console.firebase.google.com/
2. Click "Add project"
3. Enter project name: `employee-attendance-app`
4. Disable Google Analytics (optional)
5. Click "Create project"

### 7.2 Add Android App

1. In Firebase Console, click the Android icon
2. Package name: `com.example.employee_attendance_app`
3. App nickname: `Employee Attendance`
4. Click "Register app"

### 7.3 Download Configuration

1. Click "Download google-services.json"
2. Save it to this location in the project:
   `employee_attendance_app\android\app\google-services.json`

### 7.4 Enable Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create Database"
3. Choose "Start in test mode" (allows read/write)
4. Select a location near you
5. Click "Enable"

---

## Step 8: Update App Configuration

### 8.1 Update Firebase Options

Open the file: `employee_attendance_app\lib\firebase_options.dart`

Replace the placeholder values with your Firebase credentials from `google-services.json`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_API_KEY_FROM_GOOGLE_SERVICES_JSON',
  appId: 'YOUR_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

### 8.2 Update Android Build Files

Open: `employee_attendance_app\android\build.gradle.kts`

Find the `allprojects` section and replace it with:
```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

Open: `employee_attendance_app\android\app\build.gradle.kts`

1. Add the Firebase plugin in the plugins section:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}
```

2. Update minSdk to 21:
```kotlin
defaultConfig {
    applicationId = "com.example.employee_attendance_app"
    minSdk = 21
    targetSdk = flutter.targetSdkVersion
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}
```

---

## Step 9: Run the App

### Option A: Using VS Code (Recommended for Beginners)

#### 9.1 Install VS Code Flutter Extensions

1. Open VS Code
2. Click the Extensions icon (or press Ctrl+Shift+X)
3. Search for and install:
   - **Flutter** (by Dart Code)
   - **Dart** (by Dart Code)

#### 9.2 Create an Android Emulator

1. In VS Code, press `Ctrl+Shift+P`
2. Type: `Flutter: Launch Emulator`
3. Select "Create Android Emulator"
4. Choose a device (recommended: "Pixel 4" or "Pixel 5")
5. Wait for the emulator to download and start

#### 9.3 Run the App in VS Code

1. Open the project in VS Code:
   - File > Open Folder
   - Select `employee_attendance_app` folder

2. Wait for Flutter analysis to complete (bottom bar shows "Analyzing...")

3. Select the emulator from the bottom-right dropdown:
   - Look for "No Device Selected" or "Pixel 4 API..."
   - Click and select your emulator

4. Press `F5` or click the "Run" button (green play icon) in the top-right

5. The app will build and launch on the emulator

### Option B: Using Command Line

#### 9.4 Run Using Command Prompt

1. Open Command Prompt
2. Navigate to the project:
   ```cmd
   cd path\to\employee_attendance_app
   ```

3. List available emulators:
   ```cmd
   flutter emulators
   ```

4. Start an emulator:
   ```cmd
   flutter emulators --launch <emulator_id>
   ```

5. Run the app:
   ```cmd
   flutter run
   ```

### Option C: Using Android Studio

1. Open Android Studio
2. Click "Open" and select the `employee_attendance_app` folder
3. Wait for Gradle sync to complete
4. Click the green "Run" button in the toolbar
5. Select an emulator or connected device

---

## Troubleshooting VS Code Issues

### Issue: "Flutter SDK not found" in VS Code
**Fix:** 
1. Press `Ctrl+,` to open Settings
2. Search for "Flutter SDK path"
3. Click "Edit in settings.json"
4. Add: `"dart.flutterSdkPath": "C:\\flutter"`

### Issue: "No devices available" in VS Code
**Fix:**
1. Make sure an emulator is running
2. Or enable USB debugging on your phone and connect it
3. Click "No Device Selected" in bottom bar and refresh

### Issue: "Build failed" with red errors in VS Code
**Fix:**
1. Open terminal in VS Code (View > Terminal)
2. Run: `flutter clean`
3. Run: `flutter pub get`
4. Try building again

### Issue: "Gradle sync failed" in VS Code
**Fix:**
1. Close VS Code
2. Delete the `build` folder in the project
3. Reopen VS Code and wait for Gradle to sync

### Issue: "flutter: command not found"
**Fix:** Restart Command Prompt/VS Code after adding to PATH

### Issue: Android SDK not found
**Fix:** Run `flutter doctor` - it will tell you the path, then set ANDROID_HOME environment variable

### Issue: Build errors
**Fix:** Run `flutter clean` then `flutter pub get`

### Issue: Firebase connection errors
**Fix:** 
1. Check internet connection
2. Verify google-services.json is in the correct folder
3. Check package name matches in Firebase Console

---

## Quick Reference Commands

```cmd
# Check Flutter installation
flutter --version

# Check for issues
flutter doctor

# Get dependencies
flutter pub get

# Clean build
flutter clean

# Build debug APK
flutter build apk --debug

# Run on connected device
flutter run
```

---

## Project Structure

After setup, your project should look like:

```
employee_attendance_app/
├── android/              # Android configuration
├── lib/
│   ├── main.dart         # App entry point
│   ├── firebase_options.dart
│   ├── models/
│   │   ├── employee.dart
│   │   └── attendance.dart
│   ├── services/
│   │   └── firebase_service.dart
│   └── screens/
│       ├── home_screen.dart
│       ├── employee_registration_screen.dart
│       └── attendance_screen.dart
├── pubspec.yaml          # Dependencies
└── README.md             # Documentation
```

---

## Need Help?

If you encounter any issues not covered here:
1. Search for the error message on Google
2. Check Flutter documentation: https://docs.flutter.dev/
3. Check Firebase documentation: https://firebase.google.com/docs

---

## Next Steps After Running

Once the app is running:
1. Go to "Register" tab to add employees
2. Go to "Attendance" tab to mark attendance
3. Try the search feature
4. Try changing dates

The app saves all data to your Firebase Firestore database!
