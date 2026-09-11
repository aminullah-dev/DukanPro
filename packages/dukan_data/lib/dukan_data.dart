/// DukanPro data layer — implements dukan_core ports over SQLite (Drift).
/// Also exposes in-memory implementations for tests and placeholders.
library;

export 'database.dart';
export 'src/catalog_store.dart';
export 'src/in_memory.dart';
export 'src/sales_store.dart';
