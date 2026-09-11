"""DTO -> JSON-ready dict serializers shared by the routers."""

from __future__ import annotations

from dukan.application.catalog import ProductView
from dukan.application.customers import CustomerView
from dukan.application.dto import AuthenticatedUser, AuthResult, AuthTokens
from dukan.application.purchasing import GoodsReceiptView, SupplierView
from dukan.application.sales import SaleView, ShiftView


def profile_dict(p: AuthenticatedUser) -> dict:
    return {
        "id": p.id,
        "username": p.username,
        "display_name": p.display_name,
        "default_branch_id": p.default_branch_id,
        "branches": [
            {
                "branch_id": b.branch_id,
                "branch_name": b.branch_name,
                "role_name": b.role_name,
            }
            for b in p.branches
        ],
    }


def tokens_dict(t: AuthTokens) -> dict:
    return {
        "access_token": t.access_token,
        "refresh_token": t.refresh_token,
        "token_type": t.token_type,
    }


def auth_result(r: AuthResult) -> dict:
    return {"user": profile_dict(r.user), "tokens": tokens_dict(r.tokens)}


def product_view_dict(v: ProductView) -> dict:
    return {
        "id": v.id,
        "sku": v.sku,
        "name": v.name,
        "unit_id": v.unit_id,
        "sell_price_minor": v.sell_price_minor,
        "sell_currency": v.sell_currency,
        "category_id": v.category_id,
        "track_stock": v.track_stock,
        "is_active": v.is_active,
        "on_hand": v.on_hand,
        "barcodes": list(v.barcodes),
    }


def sale_view_dict(v: SaleView) -> dict:
    return {
        "id": v.id,
        "number": v.number,
        "branch_id": v.branch_id,
        "status": v.status,
        "currency": v.currency,
        "subtotal_minor": v.subtotal_minor,
        "discount_minor": v.discount_minor,
        "total_minor": v.total_minor,
        "paid_minor": v.paid_minor,
        "change_minor": v.change_minor,
        "customer_id": v.customer_id,
        "lines": [
            {
                "product_id": l.product_id,
                "name": l.name,
                "qty_minor": l.qty_minor,
                "unit_price_minor": l.unit_price_minor,
                "line_total_minor": l.line_total_minor,
            }
            for l in v.lines
        ],
    }


def shift_view_dict(v: ShiftView) -> dict:
    return {
        "id": v.id,
        "status": v.status,
        "opening_float_minor": v.opening_float_minor,
        "expected_cash_minor": v.expected_cash_minor,
        "counted_cash_minor": v.counted_cash_minor,
        "variance_minor": v.variance_minor,
    }


def customer_view_dict(v: CustomerView) -> dict:
    return {
        "id": v.id,
        "name": v.name,
        "phone": v.phone,
        "credit_limit_minor": v.credit_limit_minor,
        "currency": v.currency,
        "balance_minor": v.balance_minor,
    }


def supplier_view_dict(v: SupplierView) -> dict:
    return {
        "id": v.id,
        "name": v.name,
        "phone": v.phone,
        "currency": v.currency,
        "balance_minor": v.balance_minor,
    }


def goods_receipt_view_dict(v: GoodsReceiptView) -> dict:
    return {
        "id": v.id,
        "number": v.number,
        "supplier_id": v.supplier_id,
        "total_cost_minor": v.total_cost_minor,
    }
