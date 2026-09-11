"""0007 — performance indexes on hot query paths (Phase 10).

Revision ID: 0007
Revises: 0006
Create Date: 2026-09-11
"""

from alembic import op

revision = "0007"
down_revision = "0006"
branch_labels = None
depends_on = None

# (index name, table, columns) — narrow indexes for the reporting/insight scans
# and the audit trail. Kept idempotent-friendly via if_not_exists where the
# backend supports it (SQLite + Postgres both do for CREATE INDEX IF NOT EXISTS).
_INDEXES = [
    ("ix_sales_branch_occurred", "sales", ["branch_id", "occurred_at"]),
    ("ix_stock_movements_product_branch", "stock_movements", ["product_id", "branch_id"]),
    ("ix_sale_lines_product", "sale_lines", ["product_id"]),
    ("ix_audit_entries_occurred", "audit_entries", ["occurred_at"]),
    ("ix_audit_entries_actor", "audit_entries", ["actor_id"]),
    ("ix_audit_entries_action", "audit_entries", ["action"]),
]


def upgrade() -> None:
    for name, table, cols in _INDEXES:
        op.create_index(name, table, cols, if_not_exists=True)


def downgrade() -> None:
    for name, table, _cols in _INDEXES:
        op.drop_index(name, table_name=table, if_exists=True)
