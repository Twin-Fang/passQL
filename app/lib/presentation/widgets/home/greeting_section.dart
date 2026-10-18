import 'package:flutter/material.dart';
import '../../../data/models/home/greeting_response.dart';
import '../../design/design.dart';

/// 홈 화면 인사 영역.
/// 첫 줄이 large title 한 줄에 들어가면 large title 로 올라가고(`resolveMessage`), 여기서는 둘째 줄 본문과
/// messageType 에 따른 서브 배지를 그린다. 첫 줄이 길면 large title 은 '홈', 첫 줄은 여기서 여러 줄로 그린다.
/// 그릴 것이 없으면 호출 측이 목록에 넣지 않는다.
class GreetingSection extends StatelessWidget {
  final GreetingResponse greeting;

  /// true > 첫 줄(인사)도 여기서 그림 (large title 에 들어가지 않을 때)
  final bool isHeadlineShown;

  const GreetingSection({
    super.key,
    required this.greeting,
    this.isHeadlineShown = false,
  });

  /// large title 한 줄에 첫 줄이 다 들어가는지 (iOS large title 은 한 줄 규격 > 넘치면 본문으로 내림)
  static bool fitsInLargeTitle(
    String message, {
    required double maxWidth,
    required TextScaler textScaler,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: message, style: PassqlTypography.largeTitle),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
      maxLines: 1,
    )..layout(maxWidth: maxWidth);
    final isFit = !painter.didExceedMaxLines;
    painter.dispose();
    return isFit;
  }

  /// {nickname} 치환 후 줄 단위로 나눈다. 서버는 "닉네임님,\n본문" 두 줄로 보낸다.
  static List<String> _lines(GreetingResponse greeting) =>
      greeting.message.replaceAll('{nickname}', greeting.nickname).split('\n');

  /// large title 에 넣는 첫 줄. `\n`이 없으면 전체 문구.
  static String resolveMessage(GreetingResponse greeting) =>
      _lines(greeting).first;

  /// 둘째 줄 이후 본문. 비어 있으면 null.
  static String? resolveBody(GreetingResponse greeting) {
    final lines = _lines(greeting);
    if (lines.length < 2) return null;
    final body = lines.sublist(1).join('\n').trim();
    return body.isEmpty ? null : body;
  }

  /// 인사(내려온 경우)·본문·배지 중 그릴 것이 있는지. 없으면 목록에 넣지 않는다.
  static bool hasContent(
    GreetingResponse greeting, {
    bool isHeadlineShown = false,
  }) =>
      isHeadlineShown ||
      resolveBody(greeting) != null ||
      _subTextFor(greeting.messageType) != null;

  static String? _subTextFor(String type) {
    switch (type) {
      case 'EXAM_DAY':
        return '오늘 시험이에요!';
      case 'URGENT':
        return '시험이 얼마 남지 않았어요';
      case 'COUNTDOWN':
        return '시험까지 카운트다운 중이에요';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final body = resolveBody(greeting);
    final sub = _subTextFor(greeting.messageType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // large title 에 못 올라간 긴 인사: 말줄임 없이 단어 단위 여러 줄
        if (isHeadlineShown) ...[
          PassqlKeepAllText(
            resolveMessage(greeting),
            style: PassqlTypography.title2.copyWith(color: colors.label),
          ),
          if (body != null || sub != null)
            const SizedBox(height: PassqlSpacing.xs),
        ],
        // 줄 제한 없이 그려 둘째 줄이 잘리지 않게 한다.
        if (body != null)
          PassqlKeepAllText(
            body,
            style: PassqlTypography.title3.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        if (body != null && sub != null)
          const SizedBox(height: PassqlSpacing.xs),
        if (sub != null)
          PassqlBadge(
            text: sub,
            kind: greeting.messageType == 'EXAM_DAY'
                ? PassqlBadgeKind.important
                : PassqlBadgeKind.warning,
          ),
      ],
    );
  }
}
