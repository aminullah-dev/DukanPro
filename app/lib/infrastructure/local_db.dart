import 'dart:io';

import 'package:drift/native.dart';
import 'package:dukan_data/dukan_data.dart';
import 'package:path_provider/path_provider.dart';

/// Opens the on-device SQLite database (used in main; tests use an in-memory
/// database instead).
Future<AppDatabase> openAppDatabase() async {
  final dir = await getApplicationSupportDirectory();
  final file = File('${dir.path}/dukanpro.sqlite');
  return AppDatabase(NativeDatabase.createInBackground(file));
}
