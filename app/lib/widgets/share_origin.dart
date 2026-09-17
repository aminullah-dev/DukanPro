import 'package:flutter/widgets.dart';

/// Where on screen a share sheet should point from: the control that opened
/// it. An iPad and a Mac need one; a phone ignores it.
Rect? shareOriginOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return null;
  return box.localToGlobal(Offset.zero) & box.size;
}
