"""ReportsService port + DTOs. Read-only projections over the ledgers."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol

from dukan.domain.identity import User


@dataclass(frozen=True, slots=True)
class TopSellerView:
    name: str
    qty_minor: int


@dataclass(frozen=True, slots=True)
class DashboardView:
    sales_today_minor: int
    profit_today_minor: int
    outstanding_debt_minor: int
    low_stock_count: int
    top_sellers: tuple[TopSellerView, ...]


class ReportsService(Protocol):
    def dashboard(self, *, actor: User, branch_id: str) -> DashboardView: ...
