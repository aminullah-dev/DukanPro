# Bilingual domain glossary

Fixes the vocabulary so an i18n key is coined **once** and used consistently across UI, receipts, and reports. The key stem is the stable contract; the translations are not.

> **Status: working draft — requires native Dari & Pashto review before the UI string freeze.** Commercial/legal terms in Afghan Dari differ from Iranian Persian, and Pashto has regional variants. Terms below are reasonable defaults for a shopkeeper audience; a native reviewer should confirm each before Phase 3 (POS) ships.

| Concept | i18n key stem | English | Dari (`fa-AF`) | Pashto (`ps`) |
|---|---|---|---|---|
| Shop | `term.shop` | Shop | دکان | دوکان |
| Branch | `term.branch` | Branch | شعبه | څانګه |
| Product / item | `term.product` | Product | جنس / محصول | توکی / جنس |
| Category | `term.category` | Category | دسته‌بندی | کټګوري |
| Unit (of measure) | `term.unit` | Unit | واحد | واحد |
| Barcode | `term.barcode` | Barcode | بارکد | بارکوډ |
| Inventory / stock | `term.stock` | Stock | موجودی | ذخیره / موجودي |
| Quantity | `term.quantity` | Quantity | تعداد / مقدار | اندازه / شمېر |
| Price | `term.price` | Price | قیمت | بیه |
| Cost | `term.cost` | Cost | قیمت خرید | د پیرود بیه |
| Discount | `term.discount` | Discount | تخفیف | تخفیف |
| Tax | `term.tax` | Tax | مالیه | مالیه |
| Sale | `term.sale` | Sale | فروش | پلور |
| Invoice / bill | `term.invoice` | Invoice | فاکتور / بل | بیل / فاکتور |
| Receipt | `term.receipt` | Receipt | رسید | رسید |
| Payment | `term.payment` | Payment | پرداخت | تادیه / ورکړه |
| Cash | `term.cash` | Cash | نقد | نغدي |
| Customer | `term.customer` | Customer | مشتری | پیرودونکی / مشتري |
| Debt / credit (nasia) | `term.debt` | Debt | قرض / نسیه | پور / اُدهار |
| Balance | `term.balance` | Balance | بیلانس / باقی‌مانده | پاتې / بیلانس |
| Supplier | `term.supplier` | Supplier | تأمین‌کننده | عرضه‌کوونکی |
| Purchase | `term.purchase` | Purchase | خرید | پیرود |
| Purchase order | `term.purchase_order` | Purchase order | سفارش خرید | د پیرود فرمایش |
| Report | `term.report` | Report | گزارش / راپور | راپور |
| Employee | `term.employee` | Employee | کارمند | کارکوونکی |
| Shift / register session | `term.shift` | Shift | شیفت | شیفت |

## Conventions for keys

- Action keys: `<aggregate>.action.<verb>` — e.g. `sale.action.charge`, `debt.action.record_payment`.
- Error keys mirror error codes: code `STOCK_INSUFFICIENT` → key `stock.error.insufficient`.
- Label keys: `<aggregate>.label.<field>` — e.g. `product.label.price`.
- Terms above are for the `term.*` namespace, reused inside sentences via parameters, never concatenated.
