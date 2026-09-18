import 'dart:io';
import 'dart:ui' show Rect;

import 'package:dukan_core/dukan_core.dart' show newId;
import 'package:file_picker/file_picker.dart' show FilePicker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a file to the platform's share sheet, from which it goes on by
/// WhatsApp, Telegram, email, Bluetooth or into Files. [origin] is where the
/// sheet points from on an iPad or a Mac, which needs one. Completes false when
/// the sheet was closed without choosing anywhere to send it.
typedef ShareFile = Future<bool> Function(String path, {required String mimeType, Rect? origin});

/// Lets the person choose a file, and returns the path of a copy of it written
/// into [into], or null when they chose none.
typedef PickFile = Future<String?> Function(Directory into);

Future<bool> _shareWithPlatform(String path, {required String mimeType, Rect? origin}) async {
  final result = await SharePlus.instance.share(
    ShareParams(files: [XFile(path, mimeType: mimeType)], sharePositionOrigin: origin),
  );
  return result.status != ShareResultStatus.dismissed;
}

Future<String?> _pickWithPlatform(Directory into) async {
  final file = await FilePicker.pickFile();
  if (file == null) return null;
  // Copied, not read in place: on Android what was chosen may be a content URI
  // that no file path reaches.
  final copy = File('${into.path}/dukanpro-picked-${newId()}');
  final sink = copy.openWrite();
  try {
    await sink.addStream(file.readAsByteStream());
  } finally {
    await sink.close();
  }
  return copy.path;
}

final shareFileProvider = Provider<ShareFile>((ref) => _shareWithPlatform);

final pickFileProvider = Provider<PickFile>((ref) => _pickWithPlatform);

/// Where files made to be sent, and copies of chosen ones, are written: the
/// app's temporary directory, which the system may empty.
final workDirectoryProvider = Provider<Future<Directory> Function()>((ref) => getTemporaryDirectory);
