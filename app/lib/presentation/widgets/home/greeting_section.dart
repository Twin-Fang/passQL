import 'package:flutter/material.dart';
import '../../../data/models/home/greeting_response.dart';
import '../../design/design.dart';

/// 홈 화면 인사 영역.
/// 첫 줄은 large title 로 올라가고(`resolveMessage`), 여기서는 둘째 줄 본문과
/// messageType 에 따른 서브 배지를 그린다. 둘 다 없으면 호출 측이 목록에 넣지 않는다.
class GreetingSection extends StatelessWidget {
  final GreetingResponse greeting;

  const GreetingSection({super.key, required this.greeting});

  /// {nickname} 치환 후 줄 단위로 나눈다. 서버는 "닉네임님,\n본문" 두 줄로 보낸다.
  static List<String> _lines(GreetingResponse g) =>
      g.message.replaceAll('{nickname}', g.nickname).split('\n');

  /// large title 에 넣는 첫 줄. `\n`이 없으면 전체 문구.
  static String resolveMessage(GreetingResponse g) => _lines(g).first;

  /// 둘째 줄 이후 본문. 비어 있으면 null.
  static String? resolveBody(GreetingResponse g) {
    final lines = _lines(g);
    if (lines.length < 2) return null;
    final body = lines.sublist(1).join('\n').trim();
    return body.isEmpty ? null : body;
  }

  /// 본문이나 배지 중 그릴 것이 있는지. 없으면 목록에 넣지 않는다.
  static bool hasContent(GreetingResponse g) =>
      resolveBody(g) != null || _subTextFor(g.messageType) != null;

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
    final c = context.pq;
    final body = resolveBody(greeting);
    final sub = _subTextFor(greeting.messageType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 줄 제한 없이 그려 둘째 줄이 잘리지 않게 한다.
        if (body != null)
          Text(body, style: PqType.title3.copyWith(color: c.secondaryLabel)),
        if (body != null && sub != null) const SizedBox(height: PqSpace.xs),
        if (sub != null)
          PqBadge(
            text: sub,
            color: greeting.messageType == 'EXAM_DAY' ? c.wrong : c.warning,
          ),
      ],
    );
  }
}
