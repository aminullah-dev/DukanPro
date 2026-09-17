import 'package:dukan_core/dukan_core.dart';
import 'package:dukan_data/dukan_data.dart';

/// Where [loadDeviceId] keeps this install's id: a setting that belongs to the
/// device, never to a shop restored onto it.
const deviceIdSettingKey = 'device.id';

/// This install's id, made once and kept in the local database. The server tells
/// devices apart by it (sessions, sync audit), and sale numbers carry it, so two
/// tills never issue the same number.
Future<String> loadDeviceId(AppDatabase db) async {
  final settings = SettingsStore(db);
  final saved = await settings.get(deviceIdSettingKey);
  if (saved != null && saved.isNotEmpty) return saved;
  final id = newId();
  await settings.set(deviceIdSettingKey, id);
  return id;
}
