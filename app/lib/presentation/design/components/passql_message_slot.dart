import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 문구 종류 3개 > 글자색: 안내(보조), 오류(빨강), 확인됨(강조)
enum PassqlMessageSlotTone { neutral, error, positive }

/// 입력 아래 안내·오류 문구 자리: 최소 높이만 고정(나타나도 레이아웃이 밀리지 않게), 긴 문구는 줄바꿈으로 늘어남
/// 의견 작성·닉네임 변경·문제 신고·의견 신고 시트 공통 (#995)
class PassqlMessageSlot extends StatelessWidget {
  const PassqlMessageSlot({
    super.key,
    required this.message,
    this.tone = PassqlMessageSlotTone.error,
  });

  /// null 이면 빈 자리만
  final String? message;
  final PassqlMessageSlotTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final messageText = message;
    final textColor = switch (tone) {
      PassqlMessageSlotTone.neutral => colors.secondaryLabel,
      PassqlMessageSlotTone.error => colors.wrongText,
      PassqlMessageSlotTone.positive => colors.accentText,
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: PassqlSize.messageSlotHeight,
        minWidth: double.infinity,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: messageText == null
            ? null
            : Text(
                messageText,
                style: PassqlTypography.caption.copyWith(color: textColor),
              ),
      ),
    );
  }
}
