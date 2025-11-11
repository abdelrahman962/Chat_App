# Firebase Configuration Fix

## Problem
The error `CONFIGURATION_NOT_FOUND` occurs because your Firebase project's `google-services.json` has empty `oauth_client` arrays, which means the Firebase Authentication isn't properly configured in the Firebase Console.

## Solution

### Step 1: Enable Email/Password Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **chatapp-b78d8**
3. Click on **Authentication** in the left sidebar
4. Click on **Get Started** (if not already enabled)
5. Click on the **Sign-in method** tab
6. Find **Email/Password** in the list
7. Click on it and toggle **Enable**
8. Click **Save**

### Step 2: Download Updated google-services.json

1. In Firebase Console, go to **Project Settings** (gear icon near top-left)
2. Scroll down to **Your apps** section
3. Find your Android app: `com.example.chat_app`
4. Click on **google-services.json** download button
5. Replace the file at: `android/app/google-services.json`

### Step 3: Add SHA-1 Fingerprint (Important for Android)

1. Open terminal in your project root
2. Run this command to get your debug SHA-1:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   On Windows:
   ```powershell
   cd android
   .\gradlew.bat signingReport
   ```

3. Look for the SHA-1 fingerprint under `Variant: debug`
4. Copy the SHA-1 value (looks like: `A1:B2:C3:...`)
5. In Firebase Console → Project Settings → Your apps
6. Click **Add fingerprint**
7. Paste the SHA-1 and click **Save**
8. Download the updated `google-services.json` again

### Step 4: Clean and Rebuild

```powershell
flutter clean
flutter pub get
cd android
.\gradlew.bat clean
cd ..
flutter run
```

## Alternative: Disable reCAPTCHA (Development Only)

If you want to quickly test without fixing the OAuth config, you can temporarily disable reCAPTCHA verification in development:

**Note: This is NOT recommended for production!**

Add to `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:

```xml
<meta-data
    android:name="firebase_auth_app_verification_disabled_for_testing"
    android:value="true" />
```

## Verification

After completing the steps above, you should see:
- No more `CONFIGURATION_NOT_FOUND` errors
- Authentication should work properly
- The `oauth_client` array in your `google-services.json` should have OAuth client entries

## Code Changes Already Applied

✅ Updated `android/app/build.gradle.kts`:
- Set explicit SDK versions (minSdk: 23, compileSdk & targetSdk: 36)
- Added `multiDexEnabled = true`
- **Note**: SDK 36 is required by dependencies (androidx.media3, androidx.activity, and various Flutter plugins)

✅ Updated `lib/services/auth_service.dart`:
- Added proper error handling with rethrow
- Added `getFirebaseAuthErrorMessage()` method for user-friendly errors
- Added `register()` and `logout()` methods

✅ Updated `lib/pages/login_page.dart`:
- Added try-catch for Firebase exceptions
- Added loading state with spinner
- Added SnackBar for user feedback
- Prevents multiple login attempts during loading

## Next Steps

1. Follow the Firebase setup steps above
2. Test login with a test account
3. Create a registration page
4. Add navigation to home page after successful login
