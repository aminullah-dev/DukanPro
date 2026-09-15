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

- AFN, 2 minor digits, integer minor units. Every branch trades in AFN for now (decided 2026-09-14): another branch currency is refused with `BRANCH_CURRENCY_INVALID`. USD, PKR and EUR amounts that already exist still display with their own sign. Currency symbol and placement are locale-formatted, never hardcoded.

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

## In the app

- **A failure reads as a sentence.** `appErrorText` (`app/lib/widgets/error_text.dart`) maps every error code from the device or the server to a sentence. A code with no sentence of its own reads as its family (gone, changed meanwhile, not accepted), and anything else as a generic failure. Screens show `ErrorMessage(e)`, never `'$e'` or a code, and `tools/check_ui_literals.py` fails the build on either. It also refuses an exception's text in any label, a fixed currency code, money through a float and a time put together by hand. `tools/check_l10n_parity.py` refuses a currency written into a message: an amount carries its own through `formatMoney`.
- **Codes stored as data get labels** (`app/lib/widgets/labels.dart`, roles in `iam_ui.dart`): roles, audit actions (with the actor's name), time zones and currencies. The built-in units are labelled by their fixed ids; a shop's own units keep the name the shop gave them.
- **Numbers inside sentences are placeholders** formatted in the locale's digits (`"format": "decimalPattern"`), so one sentence never mixes ۱ and 2. Translations type no digits of their own, except the two input examples.
- **`app_fa.arb` copies `app_fa_AF.arb`** (it serves a device set to Persian). `tools/check_l10n_parity.py` keeps the two identical. It also checks placeholders against the English template, `@@locale`, and that no English is left in a translation.
- **The chosen language is saved** on the device and used from the next launch, the sign-in screen included.
- **Pashto borrows the Persian Cupertino strings.** Flutter ships none for Pashto, so this is what keeps the copy and paste menu working on iOS and macOS.
- **No English defaults:** first-run setup requires a shop name (the server refuses a blank one), and the biometric prompt is translated.
- **Dates and times are read on the branch's clock**, never the device's: the zone comes from the branch in the profile. Dari and Pashto show the Solar Hijri date with Persian digits ("۲۰ سنبله ۱۴۰۵، ۱۴:۳۰"), English the Gregorian one (`app/lib/widgets/dates.dart`). The calendar is `SolarHijriDate` in dukan_core, tested against known dates and day by day for 1390–1420. A receipt prints both calendars in ASCII: `1405-06-20 14:30 (2026-09-11)`.
- **Money reads as a figure:** from integer minor units, grouped by thousands in Latin digits (figures stay Latin), and isolated so a minus stays in front in a right-to-left line. The currency follows as the locale writes it (`formatMoney` in `app/lib/widgets/money.dart`). A price keeps its product's currency when edited; a new one, a cart total, a balance or a typed amount takes the branch's.
- **Latin tokens are isolated** left to right inside Dari and Pashto lines (`ltr()`): phone numbers, usernames, SKUs, amounts. Phone fields are typed left to right.
- **Barcode scans are layout-proof:** a keyboard-wedge scanner's keys are read from their physical position, so a Dari or Pashto keyboard layout cannot turn a code into Persian digits or Arabic letters. Codes typed with Persian digits are normalized before lookup.
- **Counts that mean something:** an insight about a product never sold counts the days since it was added, not a placeholder, and a disabled account is told so instead of "sign in again".
