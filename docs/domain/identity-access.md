# Identity & Access

**Purpose:** who may do what, in which branch. (Phases 1 and 7.)

## Entities & value objects

- **User** — `{ id, username, display_name, password_hash, status(active|disabled), default_branch_id }`. Employees are Users with roles + branch assignments.
- **Role** — `{ id, name, permissions: set<Permission> }`. Built-in roles: `owner`, `manager`, `cashier`, `stock_keeper`, `accountant`.
- **Permission** — a value object, dotted code: `sale.create`, `price.change`, `stock.adjust`, `product.manage`, `user.manage`, `report.view`, `branch.manage`, `debt.write_off`, `audit.view`, and the money actions `sale.void`, `sale.discount`, `customer.credit`, `purchase.cost` (owner and manager only).
- **BranchAssignment** — `{ user_id, branch_id, role_id }` (a user may work in several branches, with a role per branch).
- **Session** — `{ id, user_id, device_id, issued_at, expires_at, refresh_token_hash, prev_refresh_hash }`. A refresh rotates the hash in place; `expires_at` is never extended. Presenting the rotated-out token again revokes the session, except within 60 seconds of that rotation: a device whose refresh answer was lost may retry once, and the retry rotates again. A sign-out ends the session with either token, since a renewal may still be in flight when the device signs out.

## Invariants

1. A User has **at least one** BranchAssignment (except the bootstrap owner before any branch exists), and `default_branch_id` is always one of them: revoking the default re-points it (`USER_LAST_ASSIGNMENT` when it is the last).
2. A permission check is evaluated in the **application layer** against the user's role **in the target's scope**, never in the UI:
   - the branch the row or document belongs to;
   - the branch a role is granted in (granting `owner` needs owner rights there);
   - every branch a user works in, when acting on that user (status, password); acting on an owner needs owner rights in all of them.
3. `owner` implies all permissions **in its branch**. Every branch keeps at least one active owner (`USER_LAST_OWNER`), so no branch can become unadministrable. Opening a branch is a shop-wide act (`branch.manage` in every branch) and makes the shop's owners owners of the new branch.
   - Some active user also keeps owning every branch (`USER_LAST_OWNER`, scope `shop`): they open branches and read the audit trail.
   - Taking an owner role away (demote or revoke) needs owner rights in every branch that owner works in, so an owner of one branch cannot unseat the shop's owner there.
   - Upgrading to migration 0009 gives each branch with no active owner to its creator, and makes the owners of the shop's first branch owners of every branch (before 0009 they acted everywhere).
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
| shop keeps an owner | the only user owning every branch; B2 has another owner | step down in B2 | `USER_LAST_OWNER` (scope `shop`) |
| branch owner vs shop owner | user is owner@B2 only | demote or revoke the shop owner in B2 | `ACCESS_DENIED` |
| last assignment | cashier works in B1 only | revoke B1 | `USER_LAST_ASSIGNMENT` |
| refresh reuse | refresh token rotated over 60 s ago | present the old token again | `REFRESH_INVALID`, session revoked |
| lost refresh answer | refresh token rotated under 60 s ago | present the old token again | rotates again |

## Audit

`user.created`, `user.disabled`, `role.assigned` (also when a new branch gets its owners), `role.revoked`, `permission.changed`, `password.reset`, `session.reuse_detected`, `user.login_failed` — all audited (identity + permissions are audit-worthy).

## Sessions on the device

The server is authoritative; the device keeps just enough to work offline.
- **One cached profile.** It is the server's answer for the one signed-in user, replaced (never merged) at every sign-in and revalidation.
- **Revalidation.** After each unlock, when the server is reachable, the app re-reads `/auth/me`, refreshing the access token once if it expired.
  - New roles take effect at once.
  - `USER_DISABLED`, or a password the server no longer takes when signing in again (`INVALID_CREDENTIALS`), wipes the saved sign-in and requires an online sign-in.
  - `SESSION_REVOKED`, `REFRESH_INVALID` or `TOKEN_INVALID` end only the session: the tokens go, the user and the password stay, and the app returns to the lock screen. The password still unlocks offline within the offline window and signs in again once online; a PIN or fingerprint waits for that sign-in.
- **Token renewal.** Every API client shares one refresher. A 401 `TOKEN_EXPIRED` renews the access token once (requests that fail together share the renewal) and retries the request.
  - An answer that the session or account is over ends it as above; it is never shown as "offline".
  - After a password unlock, a session that ended renews by signing in again with that password. A request that meets the ended session meanwhile waits for that sign-in instead of undoing it.
  - Each sign-in and sign-out starts a new session on the device. An answer to a request made in an earlier one (a renewed token, "account disabled") is dropped. Token writes run one at a time, so a renewal never writes back after a sign-out or over another user's sign-in.
  - A refresh whose answer never came is asked for again at once: the server may have rotated the token already, and takes the old one back only within 60 seconds.
  - Requests time out (10 s to connect, 30 s to send or receive). Sign-out wipes the device first and tells the server best-effort.
  - If secure storage cannot be read at startup, or a sign-in cannot be saved, the sign-in screen says so (`STORAGE_UNAVAILABLE`) instead of an endless spinner.
- **Offline window.** Offline unlock works for 30 days after the server last confirmed the user, then fails with `OFFLINE_EXPIRED`.
  - The device remembers the latest time it has seen. A clock set back more than 5 minutes behind it also fails with `OFFLINE_EXPIRED`, so winding the clock back cannot keep the window open.
- **Lock.** There is a Lock action, and the app locks itself when it goes to the background or sits idle for 10 minutes.
  - Any touch, scroll or key anywhere in the app counts as activity, including screens and dialogs opened over the shell.
  - Locking keeps the saved sign-in and the POS cart.
  - When another user signs in, session state (cart, admin lists, notifications) starts empty.
- **Sign-out.** It wipes the saved sign-in, so it is always confirmed, with a warning when changes are not synced yet.
  - The lock screen offers no sign-out.
  - Instead it offers "use another account", which keeps the cached session until that sign-in succeeds. Going back keeps the POS cart.
- **Biometric unlock.** It stays off until the user opts in with their password. It accepts biometrics only (never the device PIN) and belongs to that one user.
- **Backups.** Android cloud backup and device transfer exclude all app data. The local database is not encrypted yet (SQLCipher).

## Server secrets and first run

- `DUKAN_SECRET_KEY` signs access tokens: at least 32 random characters, or the server refuses to start. Placeholder text such as `change-me` is refused too; `server/.env.example` leaves the key empty and shows how to generate one.
- The first owner account needs the server's **setup code**: `DUKAN_BOOTSTRAP_TOKEN` (12+ characters) or, when unset, a code the server logs at startup. Nobody who cannot read the server's console can claim a fresh server.

## Sync class

- User/Role/Permission/BranchAssignment: **mutable master data** (version + conflict).
- Session: **not synced** (device-local / server-issued auth artifact).
