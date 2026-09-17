import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../infrastructure/camera_scanner.dart';
import '../l10n/app_localizations.dart';

/// Opens the camera and returns the code it read, or null.
typedef CameraScan = Future<String?> Function(BuildContext context);

/// The camera scan on this device, or null where there is none (Windows, Linux,
/// the web). Tests put a fake here.
final cameraScanProvider = Provider<CameraScan?>((ref) => cameraScanSupported ? scanWithCamera : null);

/// A camera button for a search or barcode field. Build it only when
/// [cameraScanProvider] is not null, so a device without a camera keeps the
/// field's full width.
class CameraScanButton extends ConsumerWidget {
  const CameraScanButton({required this.onScanned, super.key});

  /// Called with the code the camera read; the caller checks it is still mounted.
  final void Function(String code) onScanned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(cameraScanProvider);
    return IconButton(
      tooltip: AppLocalizations.of(context).scanWithCamera,
      icon: const Icon(Icons.qr_code_scanner),
      onPressed: scan == null
          ? null
          : () async {
              final code = await scan(context);
              if (code != null) onScanned(code);
            },
    );
  }
}
