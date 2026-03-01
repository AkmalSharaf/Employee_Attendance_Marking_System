# Firebase Authentication Setup Guide

## Step-by-Step Instructions for Setting Up Firebase Authentication

---

### Step 1: Open Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Sign in with your Google account
3. Select your project: **`employee-attendance-app`** (or whatever you named it)

---

### Step 2: Enable Email/Password Authentication

1. In the Firebase Console sidebar, click **Build**
2. Expand the menu and click **Authentication**
3. Click the **Get Started** button (if not already enabled)
4. Click on **Sign-in method** tab
5. Find **Email/Password** in the list and click on it
6. Toggle **Enable** to ON
7. Optionally enable **Email link (passwordless sign-in)** if you want that feature
8. Click **Save**

![Email/Password Auth](https://firebase.google.com/docs/auth/images/firebase-auth-enable-email-password.png)

---

### Step 3: Create Your First Admin User

**Option A: Through Firebase Console (Recommended for testing)**

1. In the Authentication page, click **Users** tab
2. Click **Add user** button
3. Enter your admin email address (e.g., `admin@company.com`)
4. Enter a password (minimum 6 characters)
5. Click **Add user**

Your admin user is now created!

---

**Option B: Through Your App (For production)**

You can also create admin users directly through your app by building a registration screen, but for security reasons, it's recommended to create admins only through Firebase Console.

---

### Step 4: Verify Authentication is Working

1. Run your app:
   ```bash
   flutter run
   ```
2. The app will now show a login screen
3. Enter the admin email and password you created in Step 3
4. Click **Sign In**
5. You should be redirected to the Home Screen

---

### Step 5: (Optional) Add More Admin Users

To add more administrators:

1. Go to **Firebase Console → Authentication → Users**
2. Click **Add user**
3. Enter the new admin's email and password
4. Click **Add user**

---

### Step 6: Configure Security Rules (Optional but Recommended)

In production, you may want to add Firestore Security Rules to ensure only authenticated admins can access data.

To do this:
1. Go to **Firebase Console → Firestore Database**
2. Click **Rules** tab
3. Add rules like:

```javascript
rules version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated admins can read/write
    match /employees/{employeeId} {
      allow read, write: if request.auth != null;
    }
    match /attendance/{attendanceId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

### Troubleshooting Common Issues

| Issue | Solution |
|-------|----------|
| "No admin account found" | Make sure you created the user in Firebase Console |
| "Incorrect password" | Double-check the password (min 6 characters) |
| App crashes on login | Run `flutter clean` and `flutter pub get` |
| Firebase not initialized | Check `google-services.json` is in `android/app/` folder |

---

### Important Notes

1. **Email/Password is free** - Firebase Authentication free tier includes unlimited email/password sign-ins
2. **Password Requirements** - Minimum 6 characters (Firebase requirement)
3. **Security** - Keep your admin credentials secure and don't share them

---

### Quick Test Checklist

- [ ] Email/Password provider enabled in Firebase Console
- [ ] Admin user created with valid email
- [ ] App rebuilt after adding firebase_auth
- [ ] Login works with created credentials
- [ ] Logout returns to login screen

---

You're all set! Your app now requires admin authentication before accessing employee management and attendance features.
