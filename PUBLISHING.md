# 🚀 Publishing Guide: Gathering App

This document provides a comprehensive guide to publishing the **Gathering App** to the Google Play Store and Apple App Store.

---

## 📋 Pre-Publishing Checklist

Before you start, ensure the following are ready:
- [ ] **App Name**: Finalized display name (currently "Gathering App").
- [ ] **Bundle ID / Package Name**: Unique ID (e.g., `com.yourcompany.gathering`).
- [ ] **App Icons**: All required sizes (use `flutter_launcher_icons`).
- [ ] **Privacy Policy**: A hosted URL for your app's privacy policy.
- [ ] **Store Assets**: Screenshots, Feature Graphic (Android), and App Description.
- [ ] **Developer Accounts**: Google Play Console and Apple Developer Program.

---

## 🤖 Android Publishing (Google Play Store)

### 1. Configure the Package Name
The current package name is `com.example.gathering_app`. Change it to your own domain to avoid store rejection.
- Update `applicationId` in `android/app/build.gradle.kts`.
- Update the directory structure in `android/app/src/main/kotlin`.

### 2. Create a Release Keystore
Generate a keystore file for signing the app:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*Keep this file safe! If you lose it, you cannot update your app.*

### 3. Configure Signing in Gradle
Create a `android/key.properties` file:
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=/Users/your_user/upload-keystore.jks
```
Then update `android/app/build.gradle.kts` to reference these properties.

### 4. Build the App Bundle
Run the following command:
```bash
flutter build appbundle --release
```
The file will be located at `build/app/outputs/bundle/release/app-release.aab`.

---

## 🍎 iOS Publishing (Apple App Store)

### 1. Register App ID
Log in to the [Apple Developer Portal](https://developer.apple.com/) and register a new App ID with your Bundle identifier.

### 2. Configure Xcode
1. Open `ios/Runner.xcworkspace` in Xcode.
2. In the **General** tab, ensure the Bundle Identifier matches your App ID.
3. In the **Signing & Capabilities** tab, select your development team and ensure "Automatically manage signing" is checked.

### 3. App Store Connect
1. Create a new App in [App Store Connect](https://appstoreconnect.apple.com/).
2. Fill in the required metadata (Name, Privacy Policy, etc.).

### 4. Build and Archive
Run:
```bash
flutter build ipa --release
```
Open the generated `.xcresult` or use Xcode's **Product > Archive** to upload the build to App Store Connect.

---

## 🔥 Firebase Configuration

If you are using Firebase, ensure:
1. **SHA-1 and SHA-256 Fingerprints**: Add your release keystore fingerprints to the Firebase Console.
2. **Download Config Files**: Replace `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) if you changed the bundle ID.

---

## 🛠 Troubleshooting
- **Flavor Issues**: If using flavors, ensure you specify them in the build command (`--flavor prod`).
- **Permissions**: Double-check `AndroidManifest.xml` and `Info.plist` for required permissions (Location, Notifications).

---

## 📈 Next Steps
1. **TestFlight**: Distribute the iOS app to internal testers.
2. **Internal/Closed Testing**: Use Google Play's testing tracks before the production release.
3. **Monitor Console**: Check for any crashes or issues in the respective consoles.
