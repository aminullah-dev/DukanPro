/// DukanPro core — pure Dart domain, application ports, and shared primitives.
///
/// Layering (dependencies point inward): `ui → application → domain`.
/// This package contains `domain/`, `application/`, and `shared/` only, and
/// depends on no framework. See `docs/architecture-decision.md`.
library;

// shared primitives
export 'shared/ids.dart';
export 'shared/clock.dart';
export 'shared/money.dart';
export 'shared/errors.dart';
export 'shared/result.dart';

// domain
export 'domain/catalog.dart';
export 'domain/identity.dart';
export 'domain/inventory.dart';
export 'domain/sales.dart';

// application ports + guards (implemented outward in dukan_data / dukan_sync)
export 'application/access.dart';
export 'application/ports.dart';
