"""Numbers people type: amounts of money and quantities. Mirrors
packages/dukan_core/lib/domain/numbers.dart.

Shops type Persian (۰-۹) or Arabic-Indic (٠-٩) digits as often as Latin ones,
"٫" as the decimal separator and "٬" or "," between thousands. A value becomes
integer minor units without passing through a float."""

from __future__ import annotations

import re
from enum import StrEnum

from dukan.shared.errors import ValidationError
from dukan.shared.limits import MONEY_MAX


class NumberProblem(StrEnum):
    NOT_A_NUMBER = "not_a_number"
    TOO_PRECISE = "too_precise"
    TOO_LARGE = "too_large"


_GRAMMAR = re.compile(r"(-)?([0-9]{1,3}(?:,[0-9]{3})+|[0-9]+)?(?:\.([0-9]+))?")
_ASCII = {
    **{chr(0x06F0 + i): str(i) for i in range(10)},
    **{chr(0x0660 + i): str(i) for i in range(10)},
    "\u066b": ".",  # ARABIC DECIMAL SEPARATOR
    "\u066c": ",",  # ARABIC THOUSANDS SEPARATOR
    "\u2212": "-",  # MINUS SIGN
}


def normalize_digits(text: str) -> str:
    """text stripped, with Persian and Arabic-Indic digits, "٫", "٬" and the
    minus sign made ASCII."""
    return "".join(_ASCII.get(ch, ch) for ch in text.strip())


def parse_scaled(text: str, decimal_places: int) -> tuple[int | None, NumberProblem | None]:
    """text as a whole number of 10**-decimal_places units ("12.5" with 2 places
    is 1250), or the problem that stops it. Thousands marks must group by three;
    anything else (signs other than a leading "-", spaces inside, a trailing
    ".") is not a number."""
    m = _GRAMMAR.fullmatch(normalize_digits(text))
    if m is None:
        return None, NumberProblem.NOT_A_NUMBER
    whole = (m.group(2) or "").replace(",", "")
    frac = m.group(3) or ""
    if not whole and not frac:
        return None, NumberProblem.NOT_A_NUMBER
    if len(frac) > decimal_places:
        return None, NumberProblem.TOO_PRECISE
    magnitude = int((whole or "0") + frac.ljust(decimal_places, "0"))
    if magnitude > MONEY_MAX:
        return None, NumberProblem.TOO_LARGE
    return (-magnitude if m.group(1) else magnitude), None


def money_to_minor(text: str, decimal_places: int = 2) -> int:
    """An amount of money typed in a currency with decimal_places minor digits
    (AFN: 2). Raises ValidationError MONEY_AMOUNT_INVALID."""
    value, problem = parse_scaled(text, decimal_places)
    if value is None:
        raise ValidationError("MONEY_AMOUNT_INVALID", input=text[:32], reason=str(problem))
    return value
