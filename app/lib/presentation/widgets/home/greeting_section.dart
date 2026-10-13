import 'package:flutter/material.dart';
import '../../../data/models/home/greeting_response.dart';
import '../../design/design.dart';

/// 홈 화면 인사 영역.
/// 인사 문구 자체는 large title 로 올라가고(`resolveMessage`), 여기서는
/// messageType 에 따른 서브 배지만 그린다. 배지가 없으면 아무것도 그리지 않는다.
class GreetingSection extends StatelessWidget {
  final GreetingResponse greeting;

  const GreetingSection({super.key, required this.greeting});

  /// {nickname} 플레이스홀더를 실제 닉네임으로 치환한 인사 문구.
  static String resolveMessage(GreetingResponse greeting) =>
      greeting.message.replaceAll('{nickname}', greeting.nickname);

  /// messageType별 서브 텍스트. null이면 배지 숨김.
  String? get _subText {
    switch (greeting.messageType) {
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
    final sub = _subText;
    if (sub == null) return const SizedBox.shrink();
    final c = context.pq;
    return Align(
      alignment: Alignment.centerLeft,
      child: PqBadge(
        text: sub,
        color: greeting.messageType == 'EXAM_DAY' ? c.wrong : c.warning,
      ),
    );
  }
}
