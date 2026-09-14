# Localization & RTL

A first-class requirement, not a post-launch pass. Three locales, two directions, three calendars, two numeral systems.

| Locale | Code | Direction | Script |
|---|---|---|---|
| English | `en` | LTR | Latin |
| Dari | `fa-AF` | RTL | Perso-Arabic |
| Pashto | `ps` | RTL | Perso-Arabic |

`fa-AF` (Afghan Dari), **not** `fa` — Afghan commercial and government vocabulary differs from Iranian Persian. Default UI locale for a new install is **Dari (`fa-AF`)**; switchable anytime.

## Rules (enforced)

- **No user-visible literal in code.** Every string is a key (`sale.action.charge`, `stock.error.insufficient`). Client keys live in `app/lib/l10n/app_{en,fa_AF,ps}.arb`; server message keys in `server/resources/translations/`.
- **All three files change in the same commit.** A key present in one and missing in another fails CI (see `tools/` l10n parity check). No silent English fallback.
- **Never concatenate translated fragments.** One parameterised key per sentence; plurals via ICU `MessageFormat`.
- **Never string-format a number/date/money.** Pass it to the locale-aware formatter.

## Direction

- Logical properties only: `start`/`end`, never `left`/`right`. Flutter: rely on `Directionality` + `EdgeInsetsDirectional`; set the app `locale` and let `flutter_localizations` drive text direction.
- **Mirror:** navigation, alignment, list/table column order, progress, arrows, drawers, back gestures.
- **Do not mirror:** media controls, charts with a time axis, phone numbers, barcodes, license keys, Latin-digit figure columns.
- **Test by switching locale at runtime.** Every screen gets one RTL golden screenshot in review.

## Numerals & calendars

- **Store** Latin digits, Gregorian, UTC — always.
- **Display** is locale-selected: Dari/Pashto prose generally uses Eastern Arabic-Indic numerals (`۰۱۲۳…`); **figure tables stay Latin** and right-aligned by the decimal. Make numeral style a user preference, defaulted per locale.
- **Calendar:** Hijri Shamsi for `fa-AF`/`ps`, Gregorian for `en`, with the counterpart in parentheses on any document that leaves the shop. Conversion lives in one formatter, tested against a known-date table incl. leap years. Afghan **fiscal year** is configuration, not a constant.

## Money

- AFN, 2 minor digits, integer minor units. Also support USD/PKR/EUR (common in Afghan trade). Currency symbol/placement is locale-formatted, never hardcoded.

## Typography

- Latin: one clean family. **Perso-Arabic: a Naskh family with complete Pashto glyph coverage** — verify `ټ ډ ړ ږ ښ ګ ڼ` render (the glyphs that break in Persian-only fonts). Candidates to evaluate: Noto Naskh Arabic, Vazirmatn, or a Bahij/AWami-class face — must be license-clean for bundling.
- Never fake-bold Perso-Arabic; ship the weight. Line height ~15–20% more than Latin at the same size, set per script.
- **Fonts are bundled with the app** (`app/fonts/`, declared in `pubspec.yaml`) and embedded in exported PDFs — a receipt that renders as boxes on the customer's device is the standard failure.

## Printed documents (receipts, invoices, reports)

- Templates are **per-locale**, not one template with swapped strings (RTL needs a different column order and logo position).
- Every document carries: business number, issue date in **both** calendars, page `n of m`, legal entity name in the document's locale.
- Numbers in tables stay Latin, right-aligned by decimal, even in RTL.
- PDF export **always embeds fonts**. Demo/unlicensed state watermarks the document.

See [`docs/glossary.md`](glossary.md) for the bilingual domain vocabulary that seeds the i18n keys.

## Numbers people type

Money and quantity fields accept Persian (۰-۹) and Arabic-Indic (٠-٩) digits as well as Latin ones, `٫` or `.` as the decimal separator, and `٬` or `,` between thousands (in groups of three).
- The value becomes integer minor units without passing through a floating-point number: `numbers.dart` and `numbers.py`, checked against one shared table of examples.
- Anything else is refused with a translated message, never read as 0 or as "no limit": `MONEY_AMOUNT_INVALID`, `CATALOG_QTY_INVALID`, or `CATALOG_UNIT_PRECISION` (more decimals than the unit allows).
