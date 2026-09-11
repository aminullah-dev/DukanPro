"""DukanPro server — FastAPI backend (authoritative). Clean Architecture.

Layering (dependencies point inward): ui/infrastructure -> application -> domain.
Enforced by .importlinter. Retains the platform-core invariants (UUIDv7 ids,
integer Money, UTC time, soft delete + version, audit, error codes).
"""
