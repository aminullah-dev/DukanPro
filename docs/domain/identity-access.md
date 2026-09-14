# Identity & Access

**Purpose:** who may do what, in which branch. (Phases 1 and 7.)

## Entities & value objects

- **User** — `{ id, username, display_name, password_hash, status(active|disabled), default_branch_id }`. Employees are Users with roles + branch assignments.
- **Role** — `{ id, name, permissions: set<Permission> }`. Built-in roles: `owner`, `manager`, `cashier`, `stock_keeper`, `accountant`.
- **Permission** — a value object, dotted code: `sale.create`, `price.change`, `stock.adjust`, `product.manage`, `user.manage`, `report.view`, `branch.manage`, `debt.write_off`, `audit.view`, and the money actions `sale.void`, `sale.discount`, `customer.credit`, `purchase.cost` (owner and manager only).
- **BranchAssignment** — `{ user_id, branch_id, role_id }` (a user may work in several branches, with a role per branch).
- **Session** — `{ id, user_id, device_id, issued_at, expires_at, refresh_token_hash, prev_refresh_hash }`. A refresh rotates the hash in place; `expires_at` is never extended.

## Invariants

1. A User has **at least one** BranchAssignment (except the bootstrap owner before any branch exists), and `default_branch_id` is always one of them: revoking the default re-points it (`USER_LAST_ASSIGNMENT` when it is the last).
2. A permission check is evaluated in the **application layer** against the user's role **in the target's scope**, never in the UI:
   - the branch the row or document belongs to;
   - the branch a role is granted in (granting `owner` needs owner rights there);
   - every branch a user works in, when acting on that user (status, password); acting on an owner needs owner rights in all of them.
3. `owner` implies all permissions **in its branch**. Every branch keeps at least one active owner (`USER_LAST_OWNER`), so no branch can become unadministrable. Opening a branch is a shop-wide act (`branch.manage` in every branch) and makes the shop's owners owners of the new branch.
4. Disabling a User immediately invalidates their sessions (enforced at the auth boundary, not domain — domain only flags status).
5. Passwords are never stored or logged in plaintext; only a salted hash (argon2id) — domain holds the hash opaquely.
6. Only built-in roles can be granted until custom roles exist (`ROLE_UNKNOWN`).
7. Reads are scoped too: user and branch lists show only what the actor manages; the audit trail (shop-wide) needs `audit.view` in every branch.

## Error codes

| Code | When |
|---|---|
| `USER_DUPLICATE_USERNAME` | username already exists (active) |
| `USER_LAST_OWNER` | attempt to remove/disable the only owner |
| `ACCESS_DENIED` | actor lacks the required permission *(raised as `PermissionError` at the app layer, not domain)* |
| `ROLE_BUILTIN_IMMUTABLE` | editing/deleting a built-in role's core permissions |
| `USER_LAST_ASSIGNMENT` | revoking a user's only branch assignment |
| `ROLE_UNKNOWN` | granting a role that is not built in |
| `SETUP_TOKEN_INVALID` | first-run setup without the server's setup code |
| `TOKEN_INVALID` / `SESSION_REVOKED` | a forged or incomplete access token / a revoked, expired or reused session |

## Test table

| Case | Given | Action | Expect |
|---|---|---|---|
| cashier cannot change price | user role=cashier | `price.change` | `ACCESS_DENIED` |
| owner can manage users | user role=owner | `user.manage` | allowed |
| last owner protected | one owner exists | disable that owner | `USER_LAST_OWNER` |
| duplicate username | "ahmad" active | create "ahmad" | `USER_DUPLICATE_USERNAME` |
| per-branch role | user is manager@B1, cashier@B2 | `price.change` active branch=B2 | `ACCESS_DENIED` |
| owner of B2 acts on B1 | user is owner@B2 only | grant self owner@B1, reset B1 owner's password | `ACCESS_DENIED` |
| branch keeps an owner | sole owner of B1 | demote self or revoke the assignment | `USER_LAST_OWNER` |
| last assignment | cashier works in B1 only | revoke B1 | `USER_LAST_ASSIGNMENT` |
| refresh reuse | refresh token rotated once | present the old token again | `REFRESH_INVALID`, session revoked |

## Audit

`user.created`, `user.disabled`, `role.assigned` (also when a new branch gets its owners), `role.revoked`, `permission.changed`, `password.reset`, `session.reuse_detected`, `user.login_failed` — all audited (identity + permissions are audit-worthy).

## Server secrets and first run

- `DUKAN_SECRET_KEY` signs access tokens: at least 32 random characters, or the server refuses to start.
- The first owner account needs the server's **setup code**: `DUKAN_BOOTSTRAP_TOKEN` (12+ characters) or, when unset, a code the server logs at startup. Nobody who cannot read the server's console can claim a fresh server.

## Sync class

- User/Role/Permission/BranchAssignment: **mutable master data** (version + conflict).
- Session: **not synced** (device-local / server-issued auth artifact).
