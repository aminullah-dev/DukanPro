# Hardware

What DukanPro talks to, on which platform, and what to check before a shop relies on it.

Both kinds of hardware sit behind ports in `packages/dukan_hardware` (`BarcodeScanner`, `ReceiptPrinter`). The two vendor plugins are imported only in `app/lib/infrastructure/`, so replacing one changes a single adapter.

## What works where

| | Android | iPhone / iPad | macOS | Windows |
|---|---|---|---|---|
| Keyboard-wedge scanner (USB or Bluetooth HID) | ✓ | ✓ | ✓ | ✓ |
| Camera barcode scanning | ✓ ML Kit, model bundled in the app | ✓ Apple Vision | ✓ Apple Vision | — |
| Network printer (ESC/POS, TCP 9100) | ✓ | ✓ | ✓ | ✓ |
| Bluetooth Classic printer (SPP) | ✓ | — no iOS API | — | — |
| Bluetooth LE printer | ✓ | ✓ | — | — |
| USB printer | ✓ | — no iOS API | — | — |
| Cash drawer, opened through the printer | with any printer above | with any printer above | with any printer above | with any printer above |

**On iPhone and iPad, only BLE printers work over Bluetooth.**
- Most small receipt printers speak Bluetooth Classic (SPP). iOS lets an app use SPP only through MFi accessories that the printer's maker has approved for that app.
- A generic USB printer cannot be used from an iPhone app.
- Choose the printer with this in mind.

## Camera scanning

- **Where it appears:** the camera button sits in:
  - the till's search;
  - the product list's search;
  - a new product's barcode field and a product's barcodes;
  - the product field when receiving stock.
- **What it reads:** EAN-13, EAN-8, UPC-A, UPC-E, Code 128, Code 39, ITF-14 and QR.
- **When no product has the code:** the till says so. A keyboard-wedge scan that matches nothing stays silent, as before, because stray keys are common.
- **UPC-A codes:** a UPC-A is the same product as the EAN-13 written with a zero in front, and readers disagree about which one they report. Lookup tries the code as read, then that twin (`barcodeLookupCodes`), so a product scans the same from Android's camera, an iPhone's, or a wedge scanner.
- **Android:** `mobile_scanner` 7.4.2 with ML Kit's *bundled* model. It reads offline and never downloads a model from Google Play services.
  - Checked in the built APK: ML Kit's `libbarhopper_v3.so` and `assets/mlkit_barcode_models/*.tflite` are inside it. They add about 5 MB per processor type.
  - Do not set `dev.steenbakker.mobile_scanner.useUnbundled`; that switches to the Play services model.
  - **Not yet tried on a device without Google Play services**, such as a recent Huawei. mobile_scanner issue #1487 reports a failure there.
  - If it fails on the shop's devices, replace the adapter in `app/lib/infrastructure/camera_scanner.dart` with `flutter_zxing`, which contains no Google code.
  - When online, ML Kit sends Google diagnostic metrics about its own use. The app's privacy notice should say so.
- **iOS and macOS:** Apple's Vision framework, with no Google code.
- **Permission prompts:** on iOS and macOS they are in English, like the Face ID prompt.

## Receipt printers

- **Setting up:** Settings → Receipt printer → Connection → Find printers → choose one → Save. Test print sends a Dari or Pashto sample, in the reader's language.
- **Connections:**
  - Each print job connects, sends and closes, like the network printer. A printer that was switched off, went to sleep, or was paired again never leaves the till holding a dead connection.
  - A job over Bluetooth, BLE or USB may take up to 30 seconds, because it connects first and BLE sends the picture receipt in small pieces. A network job may take up to 10 seconds.
- **Bluetooth Classic:** printers already paired in Android's Bluetooth settings are listed first, then nearby ones. Pair the printer there if it does not show.
- **USB:** Android asks for permission the first time. It supports printer-class and USB-serial printers.
- **Package:** `unified_esc_pos_printer` 3.4.0 (BSD-3-Clause), pinned exactly.
  - It is young: first released in March 2026, and its author tested it on one printer model.
  - It does not read printer status, such as paper out.
- **Permissions:**
  - A Bluetooth search needs location only up to Android 11 (`maxSdkVersion 30`). From Android 12 it uses `BLUETOOTH_SCAN`, marked `neverForLocation`, and `BLUETOOTH_CONNECT`.
  - `network_info_plus`, which the package brings for finding network printers, adds the install-time permissions `ACCESS_NETWORK_STATE` and `ACCESS_WIFI_STATE`.
  - No hardware is required to install the app. Bluetooth, BLE, camera, USB host, location and Wi-Fi are all declared optional, so Google Play hides the app from no device for lacking one.
- **Android build:**
  - `usb_serial`, which the package uses, no longer builds with Gradle 9, so the app uses a patched copy (`third_party/usb_serial/PATCHES.md`).
  - The root Android build compiles every library against SDK 36, because `unified_esc_pos_printer` pins 34 while its dependencies require 36.
- **Licence:** it compiles `libserialport` (LGPL-3.0-or-later) from source into Android builds. The built APK was checked: it is its own shared library (`liblibserialport_plus.so`), dynamically linked. LGPL allows use in a closed-source app but carries notice and relinking duties. **Have a lawyer confirm what distributing the APK requires.**
- **Not yet tried against a physical Bluetooth or USB printer.** Test the shop's own printer, paired or plugged in, before a pilot. Print a receipt, reprint it, open the drawer, and switch the printer off and on between jobs.
