import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';

/// Whether this device can read barcodes with its camera. mobile_scanner reads
/// with ML Kit on Android, whose model is bundled in the app (so it reads
/// offline and needs no Google Play services download), and with Apple's
/// Vision on iOS and macOS.
bool get cameraScanSupported =>
    !kIsWeb &&
    switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };

/// Retail codes and QR: fewer formats read faster and misread less.
const _formats = [
  BarcodeFormat.ean13,
  BarcodeFormat.ean8,
  BarcodeFormat.upcA,
  BarcodeFormat.upcE,
  BarcodeFormat.code128,
  BarcodeFormat.code39,
  BarcodeFormat.itf14,
  BarcodeFormat.qrCode,
];

/// Opens the camera full screen and returns the first code it reads, or null
/// when the person closes it first.
Future<String?> scanWithCamera(BuildContext context) => Navigator.of(context).push<String>(
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => const _CameraScanPage()),
    );

class _CameraScanPage extends StatefulWidget {
  const _CameraScanPage();
  @override
  State<_CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<_CameraScanPage> {
  final _camera = MobileScannerController(formats: _formats, detectionSpeed: DetectionSpeed.noDuplicates);
  bool _read = false;

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_read) return; // one code per scan: the page is already closing
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue?.trim();
      if (code == null || code.isEmpty) continue;
      _read = true;
      Navigator.of(context).pop(code);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l.scanWithCamera),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _camera,
            builder: (context, state, _) => switch (state.torchState) {
              TorchState.unavailable => const SizedBox.shrink(),
              final torch => IconButton(
                  tooltip: l.cameraLight,
                  icon: Icon(torch == TorchState.on ? Icons.flashlight_on : Icons.flashlight_off),
                  onPressed: _camera.toggleTorch,
                ),
            },
          ),
        ],
      ),
      body: MobileScanner(
        controller: _camera,
        onDetect: _onDetect,
        errorBuilder: (context, error) => _CameraProblem(
          error.errorCode == MobileScannerErrorCode.permissionDenied ? l.cameraPermissionDenied : l.cameraUnavailable,
        ),
      ),
    );
  }
}

class _CameraProblem extends StatelessWidget {
  const _CameraProblem(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        ),
      );
}
