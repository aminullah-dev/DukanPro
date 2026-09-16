import 'dart:isolate';

import 'package:dukan_data/dukan_data.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';

import 'secure_store.dart';

/// Opens the on-device database (used in main; tests use an in-memory database
/// instead). It is encrypted with SQLCipher under a random key that only this
/// device's secure storage holds (review F047).
Future<AppDatabase> openAppDatabase(SecureStore keys) async {
  final dir = await getApplicationSupportDirectory();
  final path = '${dir.path}/dukanpro.sqlite';
  final key = await databaseKey(keys);
  // Off the UI isolate: encrypting a database from before reads all of it.
  final found = await Isolate.run(() => prepareEncryptedDatabase(path, key));
  if (found == DatabasePreparation.setAside) {
    // The key could not open what was there. The file is kept beside the new
    // one, and this device fills again from the server.
    debugPrint('The local database did not open with this device key; it was set aside.');
  }
  return AppDatabase(openEncryptedDatabase(path, key));
}

/// This device's database key, made the first time it is needed.
Future<String> databaseKey(SecureStore keys) async {
  final saved = await keys.read(SecureKeys.databaseKey);
  if (saved != null && isDatabaseKey(saved)) return saved;
  final key = newDatabaseKey();
  await keys.write(SecureKeys.databaseKey, key);
  return key;
}
