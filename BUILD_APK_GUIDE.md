# Building Android APK for ReportCyber

## Prerequisites

1. **Flutter SDK** installed and configured
2. **Android Studio** or **Android SDK Command-line Tools**
3. **Java JDK** 11 or higher

## Step 1: Update API URL

Before building, update the backend API URL in your app:

**File:** `frontend/lib/core/config/app_config.dart`

```dart
static const String baseUrl = 'https://your-backend-url.vercel.app/api/v1';
```

Replace `your-backend-url.vercel.app` with your actual deployed backend URL.

## Step 2: Generate Android Platform Files

If Android folder doesn't exist, create it:

```bash
cd frontend
flutter create . --platforms=android
```

This will generate the `android` folder with all necessary files.

## Step 3: Configure Android App

### Update Application ID

**File:** `frontend/android/app/build.gradle`

Find and update:
```gradle
defaultConfig {
    applicationId "com.reportcyber.app"  // Change this to your package name
    minSdkVersion 21  // Minimum Android version
    targetSdkVersion 33  // Target Android version
    versionCode 1
    versionName "1.0.0"
}
```

### Update App Name

**File:** `frontend/android/app/src/main/AndroidManifest.xml`

```xml
<application
    android:label="ReportCyber"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

## Step 4: Configure Permissions

**File:** `frontend/android/app/src/main/AndroidManifest.xml`

Add these permissions before `<application>` tag:

```xml
<!-- Required permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />

<!-- Camera feature -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

## Step 5: Build Debug APK (For Testing)

Build a debug APK to test on your device:

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --debug
```

The APK will be at: `frontend/build/app/outputs/flutter-apk/app-debug.apk`

### Install on Device

```bash
# Install via USB
flutter install

# Or manually
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## Step 6: Build Release APK (For Production)

### Option A: Build Unsigned Release APK (Quick Test)

```bash
flutter build apk --release
```

### Option B: Build Signed Release APK (Recommended)

#### 6.1 Create Signing Key

```bash
cd frontend/android/app

# Generate keystore file
keytool -genkey -v -keystore reportcyber-release-key.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias reportcyber
```

You'll be asked:
- Enter keystore password (remember this!)
- Re-enter password
- Enter your name, organization, etc.
- Enter key password (can be same as keystore password)

**IMPORTANT:** Keep this `.jks` file secure and backup somewhere safe!

#### 6.2 Create Key Properties File

**File:** `frontend/android/key.properties`

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=reportcyber
storeFile=reportcyber-release-key.jks
```

**IMPORTANT:** Add this to `.gitignore`:
```
android/key.properties
android/app/*.jks
```

#### 6.3 Configure build.gradle for Signing

**File:** `frontend/android/app/build.gradle`

Add before `android {` block:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Add inside `android {` block, before `buildTypes`:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

Update `buildTypes`:

```gradle
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

#### 6.4 Build Signed Release APK

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

The signed APK will be at: `frontend/build/app/outputs/flutter-apk/app-release.apk`

## Step 7: Build App Bundle (For Google Play Store)

For publishing to Google Play Store, build an App Bundle:

```bash
flutter build appbundle --release
```

The bundle will be at: `frontend/build/app/outputs/bundle/release/app-release.aab`

## Step 8: Test the APK

### Transfer to Phone

```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or upload to Google Drive, Dropbox, etc. and download on phone
```

### Test Checklist

- [ ] App installs successfully
- [ ] App launches without crashes
- [ ] Can register/login
- [ ] Can submit reports
- [ ] Can upload images/files
- [ ] Camera works
- [ ] Evidence verification works
- [ ] Notifications work
- [ ] All screens display correctly

## Troubleshooting

### Build Errors

**Error: "Gradle sync failed"**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Error: "Execution failed for task ':app:lintVitalRelease'"**
Add to `android/app/build.gradle`:
```gradle
android {
    lintOptions {
        checkReleaseBuilds false
    }
}
```

**Error: "JAVA_HOME not set"**
- Install JDK 11 or higher
- Set JAVA_HOME environment variable

### App Crashes

**Check logs:**
```bash
adb logcat | findstr "Flutter"
```

**Common issues:**
- Backend URL not updated (still pointing to localhost)
- Missing permissions in AndroidManifest.xml
- Network security configuration (HTTP vs HTTPS)

### HTTP Not Working (Cleartext Traffic)

If your backend uses HTTP (not HTTPS), add to `AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

## Build for Different ABIs (Optional)

Build separate APKs for different CPU architectures (smaller file sizes):

```bash
flutter build apk --split-per-abi --release
```

This creates:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (x86 64-bit)

## App Size Optimization

### Reduce APK Size

1. **Enable code shrinking** (already in config above)
2. **Split per ABI** (see above)
3. **Remove unused resources:**

```gradle
android {
    buildTypes {
        release {
            shrinkResources true
            minifyEnabled true
        }
    }
}
```

4. **Compress images** in `assets` folder
5. **Use vector graphics** instead of PNG when possible

## Publishing to Google Play Store

### Prerequisites

1. **Google Play Console Account** ($25 one-time fee)
2. **App Bundle** (`.aab` file)
3. **App assets:**
   - App icon (512x512 PNG)
   - Feature graphic (1024x500)
   - Screenshots (at least 2)
   - Privacy policy URL
   - App description

### Steps

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new application
3. Fill in store listing details
4. Upload app bundle (`.aab`)
5. Set up content rating
6. Set up pricing & distribution
7. Submit for review

### Before Publishing

- [ ] Test on multiple devices
- [ ] Test all features thoroughly
- [ ] Backend is deployed and stable
- [ ] Privacy policy created
- [ ] Terms of service created
- [ ] Support email configured
- [ ] App meets Google Play policies

## Quick Build Commands Reference

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (unsigned)
flutter build apk --release

# Release APK (signed)
flutter build apk --release --split-per-abi

# App Bundle (for Play Store)
flutter build appbundle --release

# Install on connected device
flutter install

# Clean build
flutter clean && flutter pub get && flutter build apk --release
```

## Recommended Build Process

1. Test with debug build first
2. Fix any issues
3. Update version number in `pubspec.yaml` and `build.gradle`
4. Build signed release APK
5. Test release APK on physical device
6. If all good, build app bundle for Play Store
7. Upload to Play Store or distribute APK

---

**Need Help?**
- Flutter docs: https://docs.flutter.dev/deployment/android
- Android docs: https://developer.android.com/studio/build/building-cmdline
