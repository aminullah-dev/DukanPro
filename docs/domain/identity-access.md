# Identity & Access

**Purpose:** who may do what, in which branch. (Phases 1 and 7.)

## Entities & value objects

- **User** — `{ id, username, display_name, password_hash, status(active|disabled), default_branch_id }`. Employees are Users with roles + branch assignments.
- **Role** — `{ id, name, permissions: set<Permission> }`. Built-in roles: `owner`, `manager`, `cashier`, `stock_keeper`, `accountant`.
- **Permission** — a value object, dotted code: `sale.create`, `price.change`, `stock.adjust`, `user.manage`, `report.view`, `branch.manage`, `debt.write_off`.
- **BranchAssignment** — `{ user_id, branch_id, role_id }` (a user may work in several branches, with a role per branch).
- **Session** — `{ id, user_id, device_id, issued_at, expires_at, refresh_token_hash }`.

## Invariants

1. A User has **at least one** BranchAssignment (except the bootstrap owner before any branch exists).
2. A permission check is evaluated in the **application layer** against the user's role **for the active branch** — never in the UI.
3. `owner` role implies all permissions and cannot be deleted or stripped of `user.manage`.
4. Disabling a User immediately invalidates their sessions (enforced at the auth boundary, not domain — domain only flags status).
5. Passwords are never stored or logged in plaintext; only a salted hash (argon2id) — domain holds the hash opaquely.

## Error codes

| Code | When |
|---|---|
| `USER_DUPLICATE_USERNAME` | username already exists (active) |
| `USER_LAST_OWNER` | attempt to remove/disable the only owner |
| `ACCESS_DENIED` | actor lacks the required permission *(raised as `PermissionError` at the app layer, not domain)* |
| `ROLE_BUILTIN_IMMUTABLE` | editing/deleting a built-in role's core permissions |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| cashier cannot change price | user role=cashier | `price.change` | `ACCESS_DENIED` |
| owner can manage users | user role=owner | `user.manage` | allowed |
| last owner protected | one owner exists | disable that owner | `USER_LAST_OWNER` |
| duplicate username | "ahmad" active | create "ahmad" | `USER_DUPLICATE_USERNAME` |
| per-branch role | user is manager@B1, cashier@B2 | `price.change` active branch=B2 | `ACCESS_DENIED` |

## Audit

`user.created`, `user.disabled`, `role.assigned`, `permission.changed`, `password.reset` — all audited (identity + permissions are audit-worthy).

## Sync class

- User/Role/Permission/BranchAssignment: **mutable master data** (version + conflict).
- Session: **not synced** (device-local / server-issued auth artifact).
