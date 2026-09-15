/// A left-to-right isolate (U+2066 … U+2069): a Latin token — a phone number,
/// a username, an SKU, an amount with its minus sign — keeps its own order
/// inside a Dari or Pashto line, instead of being reordered by it (a phone's
/// digit groups would read backwards, a minus would trail).
String ltr(String text) => '\u2066$text\u2069';
