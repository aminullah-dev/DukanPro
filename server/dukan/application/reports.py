"""ReportsService port + DTOs. Read-only projections over the ledgers."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class TopSellerView:
    name: str
    qty_minor: int  # in the unit's minor granularity (10**decimal_places)
    decimal_places: int = 0
    unit_name: str = ""
    revenue_minor: int = 0


@dataclass(frozen=True, slots=True)
class DashboardView:
    sales_today_minor: int
    profit_today_minor: int
    outstanding_debt_minor: int
    low_stock_count: int
    top_sellers: tuple[TopSellerView, ...]


class ReportsService(Protocol):
    def dashboard(self, *, actor: User, branch_id: str) -> DashboardView: ...
