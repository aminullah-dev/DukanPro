# usb_serial 0.5.2, patched for DukanPro

`unified_esc_pos_printer`, which prints receipts to Bluetooth and USB printers, depends on [usb_serial](https://pub.dev/packages/usb_serial) 0.5.2 (BSD-3-Clause, © 2019 Ron Bessems; see `LICENSE`). Published in July 2024, it has no maintainer, and its Android build no longer evaluates under Gradle 9 and Android Gradle Plugin 9. `app/pubspec.yaml` replaces it with this copy through `dependency_overrides`.

## What changed

Only `android/build.gradle` and `android/src/main/AndroidManifest.xml`. The Dart library (`lib/`) and the Java plugin (`android/src/main/java/`) are the published 0.5.2, byte for byte.

- `jcenter()` is gone; Gradle 9 removed it.
- The `buildscript` block pinning Android Gradle Plugin 4.1 is gone. The app's build supplies AGP 9.
- It no longer adds JitPack to **every** project's repositories (`rootProject.allprojects`).
  - Gradle resolves a library's dependencies with the app's repositories, so the app's root build (`app/android/build.gradle.kts`) declares JitPack once.
  - A content filter lets only the `com.github.felHR85` group come from it, which is this plugin's serial driver, `com.github.felHR85:UsbSerial:6.1.0`. No other dependency of the app can be served from JitPack.
- `compileSdk` 36 and `minSdk` 21, with the DSL AGP 9 reads. `lintOptions` and the extra `-Xlint` compiler flags for every project are dropped.
- The manifest no longer carries a `package` attribute; the namespace is set in `build.gradle`.

## Checked before patching

- The Java plugin implements `FlutterPlugin`, not the removed v1 `Registrar`.
- On Android 13 and later it registers its permission receiver as `RECEIVER_NOT_EXPORTED`, with a `FLAG_MUTABLE` pending intent.

## When to drop this copy

When `unified_esc_pos_printer` moves to a maintained serial package, or usb_serial publishes a release that builds with Gradle 9, remove the override from `app/pubspec.yaml` and delete this directory.
