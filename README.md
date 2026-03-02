# Employee Attendance Marking System

A Flutter application for managing employee attendance using Firebase Firestore with Firebase Authentication for admin access control.

## Features

### 1. Admin Authentication
- Secure email/password login
- Professional login screen with Material 3 design
- Auth state management (auto login/logout)
- User profile dropdown with logout option
- Only authorized admins can access the app

### 2. Employee Registration Module
- Add new employees with required fields:
  - Employee Name
  - Employee ID
  - Department
  - Contact Number
- Form validation with error messages
- Success/error notifications after submission

### 3. Attendance Marking Module
- Display list of all registered employees
- Search/filter employees by name
- Mark attendance with toggle switches
- Date selector for attendance records
- Real-time attendance summary (Present/Absent)
- Visual indicators for attendance status

## Technical Stack

- **Framework**: Flutter (latest stable)
- **Backend**: Firebase Firestore
- **Authentication**: Firebase Authentication (Email/Password)
- **State Management**: StreamBuilder with Firebase streams
- **Architecture**: Clean Architecture with separation of concerns

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase configuration
├── models/
│   ├── employee.dart              # Employee data model
│   └── attendance.dart            # Attendance data model
├── services/
│   ├── auth_service.dart          # Firebase Authentication operations
│   └── firebase_service.dart      # Firebase Firestore CRUD operations
└── screens/
    ├── auth_wrapper.dart          # Authentication state handler
    ├── login_screen.dart         # Admin login screen
    ├── employee_registration_screen.dart  # Employee registration form
    └── attendance_screen.dart    # Attendance marking screen
```

## Prerequisites

1. Flutter SDK (latest stable version)
2. Node.js (for Firebase CLI)
3. A Firebase project

## Setup Instructions

### Step 1: Clone and Install Dependencies

```bash
# Navigate to project directory
cd employee_attendance_app

# Get dependencies
flutter pub get
```

### Step 2: Set Up Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Add an iOS app (for iOS) and/or Android app (for Android)
4. Download the configuration files:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

### Step 3: Configure Firebase in the App

#### For Android:
1. Place `google-services.json` in `android/app/`
2. Open `android/build.gradle` and add:
   ```groovy
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
     }
   }
   ```
3. In `android/app/build.gradle`, add at the bottom:
   ```groovy
   apply plugin: 'com.google.gms.google-services'
   ```

#### For iOS:
1. Place `GoogleService-Info.plist` in `ios/Runner/`
2. Configure in Xcode

### Step 4: Enable Firebase Services

#### Enable Firestore Database:
1. In Firebase Console, go to "Firestore Database"
2. Click "Create Database"
3. Choose a location and start in test mode (or set appropriate rules)

#### Enable Firebase Authentication:
1. In Firebase Console, go to "Authentication"
2. Click "Get Started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password" provider
5. Click "Save"

### Step 5: Create Admin User

1. In Firebase Console, go to "Authentication" → "Users"
2. Click "Add user"
3. Enter admin email and password (min 6 characters)
4. Click "Add user"

### Step 6: Run the App

```bash
# Run on connected device/emulator
flutter run

# Or specify a target
flutter run -d <device_id>
```

## Firebase Security Rules (For Production)

When ready to deploy, update your Firestore and Authentication rules:

### Firestore Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /employees/{employee} {
      allow read, write: if request.auth != null;
    }
    match /attendance/{attendance} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Authentication Settings:
- Go to Firebase Console → Authentication → Settings
- Configure user session timeout as needed

## App Usage

### Login
1. Launch the app
2. Enter admin email and password
3. Tap "Sign In" to access the app

### Logging Out
1. Tap on the admin profile in the top-right corner
2. Select "Logout" from the dropdown
3. Confirm logout in the dialog

### Registering Employees
1. Tap "Register" in the bottom navigation
2. Fill in the employee details
3. Tap "Register Employee" to save

### Marking Attendance
1. Tap "Attendance" in the bottom navigation
2. Select a date using the calendar icon
3. Search for employees using the search bar
4. Toggle the switch to mark Present/Absent
5. View real-time summary of attendance

## Screenshots

The app features:
- Clean, Material Design 3 UI
- Professional login screen with validation
- User profile dropdown with logout
- Real-time search functionality
- Visual attendance indicators (green border for present)
- Attendance summary cards

## Authentication Features

- **Secure Login**: Email/password authentication
- **Auto State Management**: Automatically handles login/logout state
- **Professional UI**: Material 3 design with proper alignment
- **User Info Display**: Shows admin email and avatar
- **Logout Confirmation**: Dialog confirmation before logging out

## Error Handling

- Network errors are displayed as snackbar messages
- Form validation provides immediate feedback
- Authentication errors show user-friendly messages
- Empty states guide users on next steps

## License

This project is for assessment purposes.
