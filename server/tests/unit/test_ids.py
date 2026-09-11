"""Mirror of packages/dukan_core/test/ids_test.dart."""

import re

from dukan.shared.ids import new_id

_UUID = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)


def test_is_36_char_hyphenated() -> None:
    i = new_id()
    assert len(i) == 36
    assert _UUID.match(i)


def test_version_7_and_variant() -> None:
    i = new_id()
    assert i[14] == "7"          # version nibble
    assert i[19] in "89ab"       # variant nibble


def test_unique() -> None:
    assert new_id() != new_id()
