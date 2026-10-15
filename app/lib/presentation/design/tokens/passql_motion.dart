import 'package:flutter/animation.dart';

/// 애니메이션 시간·곡선.
abstract final class PassqlMotion {
  static const fast = Duration(milliseconds: 250);
  static const curve = Curves.easeOutCubic;
}
