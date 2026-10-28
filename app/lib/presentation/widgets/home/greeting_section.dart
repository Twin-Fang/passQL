import 'package:flutter/material.dart';
import '../../../data/models/home/greeting_response.dart';
import '../../design/design.dart';

/// 홈 인사 영역 (상단 바 아래 첫 줄): 인사 > 본문 > 시험 상황 배지
/// 인사·본문 모두 말줄임 없이 단어 단위 줄바꿈 (좁은 화면·큰 글자에서도 전부 보임)
class GreetingSection extends StatelessWidget {
  final GreetingResponse greeting;

  const GreetingSection({super.key, required this.greeting});

  /// {nickname} 치환 후 줄 단위로 나눈다. 서버는 "닉네임님,\n본문" 두 줄로 보낸다.
  static List<String> _lines(GreetingResponse greeting) =>
      greeting.message.replaceAll('{nickname}', greeting.nickname).split('\n');

  /// 인사 첫 줄. `\n`이 없으면 전체 문구.
  static String resolveMessage(GreetingResponse greeting) =>
      _lines(greeting).first;

  /// 둘째 줄 이후 본문. 비어 있으면 null.
  static String? resolveBody(GreetingResponse greeting) {
    final lines = _lines(greeting);
    if (lines.length < 2) return null;
    final body = lines.sublist(1).join('\n').trim();
    return body.isEmpty ? null : body;
  }

  // COUNTDOWN 은 시험 일정 카드의 D-일수와 겹쳐 배지를 두지 않음 (#648)
  static String? _subTextFor(String type) {
    switch (type) {
      case 'EXAM_DAY':
        return '오늘 시험이에요!';
      case 'URGENT':
        return '시험이 얼마 남지 않았어요';
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
        // 인사 = 홈 화면 제목: title3 > title2 로 키움 (상단 바 D-day 와 같은 크기, #701), 줄 제한 없음
        PassqlKeepAllText(
          resolveMessage(greeting),
          style: PassqlTypography.title2.copyWith(color: colors.label),
        ),
        // 본문: 인사보다 한 단계 낮은 보조 문장
        if (body != null) ...[
          const SizedBox(height: PassqlSpacing.xxs),
          PassqlKeepAllText(
            body,
            style: PassqlTypography.body.copyWith(color: colors.secondaryLabel),
          ),
        ],
        if (sub != null) ...[
          const SizedBox(height: PassqlSpacing.xs),
          PassqlBadge(
            text: sub,
            kind: greeting.messageType == 'EXAM_DAY'
                ? PassqlBadgeKind.important
                : PassqlBadgeKind.warning,
          ),
        ],
      ],
    );
  }
}
