# Android release

A shop gets DukanPro on Android as an APK installed straight onto its phones and tablets, or later from Google Play. Either way, every build must be signed with the same **upload key**.

## Why one key matters

Android installs an update only if it is signed with the same key as the app already on the device. A build signed with any other key, Flutter's debug key included, is refused. The only way past that is to uninstall the app, which **deletes the device's database**: a shop set up without a server loses its books.

- Release builds never fall back to the debug key. Without the upload key, Gradle stops before building anything and says why.
- Create the key once, before the first release reaches a shop, and keep it for as long as the app is in use.

## Create the upload key (once)

`keytool` asks for the passwords itself, so they never end up in your shell history:

```bash
keytool -genkeypair -v -keystore ~/dukanpro-upload.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

- **Keep two copies of the keystore and its password away from this Mac**, for example an encrypted USB drive in the office and a password manager.
  - If the key is lost, shops that installed the APK cannot take an update without reinstalling, and reinstalling deletes their data.
  - An app published on Google Play with Play App Signing is safer: Google holds the key that signs what shops install, and a lost upload key can be reset through Play support. APKs installed directly have no such rescue.
- Never put the keystore inside this repository. `*.jks` and `*.keystore` are ignored by git, but the key belongs with the app's owner, not with the code.

## Point the build at the key

Create `app/android/key.properties`. Git ignores this file.

```properties
storeFile=/Users/<you>/dukanpro-upload.jks
storePassword=<keystore password>
keyAlias=upload
keyPassword=<key password>
```

## Build

```bash
tools/build_android_release.sh
```

It builds against `DUKAN_API`, which defaults to `https://api.linumic.com`, using the committed dependency versions (`--enforce-lockfile`), and writes these files:

| File | For |
|---|---|
| `app/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` | nearly every phone and tablet sold in recent years |
| `app/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` | older 32-bit devices |
| `app/build/app/outputs/flutter-apk/app-x86_64-release.apk` | emulators and x86 tablets |
| `app/build/app/outputs/bundle/release/app-release.aab` | Google Play |

The version code is the number of minutes since 1970. Every build is therefore higher than the one before it and installs as an update.

## Install on a device

Copy the matching APK to the device and open it, allowing installs from that source when Android asks. If the device is connected by USB, you can use `adb` instead:

```bash
adb install -r app-arm64-v8a-release.apk
```

`-r` updates the app already installed and keeps its data. A shop set up without a server needs nothing else. A shop with a server needs that server to be reachable at `DUKAN_API`.
