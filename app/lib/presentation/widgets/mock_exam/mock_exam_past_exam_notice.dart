import 'package:flutter/widgets.dart';

import '../../design/design.dart';

/// 기출 복원 회차 면책 한 줄 (안내·결과 화면 맨 아래, #1079)
class MockExamPastExamNotice extends StatelessWidget {
  const MockExamPastExamNotice({super.key});

  static const String noticeText =
      '응시자 후기를 바탕으로 다시 구성한 문항이라 실제 시험과 표현이나 수치가 다를 수 있어요. '
      '게시 중단 요청은 의견 보내기로 알려 주세요.';

  @override
  Widget build(BuildContext context) {
    return Text(
      noticeText,
      style: PassqlTypography.footnote.copyWith(
        color: context.passqlColors.secondaryLabel,
      ),
    );
  }
}
