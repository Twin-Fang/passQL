import 'package:flutter/cupertino.dart';

import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../design/design.dart';

/// 시험 형식 안내 행들 (회차 목록 머리·시험 안내 공용): 숫자는 서버 examRule 에서만
class MockExamRuleRows extends StatelessWidget {
  const MockExamRuleRows({
    super.key,
    required this.rule,
    this.isDetailed = false,
  });

  final MockExamRule rule;

  /// 시험 안내: 자동 제출·이어 풀기·풀이 중 정답 없음까지
  final bool isDetailed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final subjectSummary = rule.subjects
        .map((subject) => '${subject.name} ${subject.questionCount}')
        .join(' · ');
    final failSummary = rule.subjects
        .map((subject) => '${subject.name} ${subject.failBelowScore}점')
        .join(', ');
    return PassqlGroupedSection(
      children: [
        _row(
          colors.accent,
          CupertinoIcons.timer,
          '${rule.durationMinutes}분 · ${rule.questionCount}문항',
          subjectSummary,
        ),
        _row(
          colors.correct,
          CupertinoIcons.checkmark_seal,
          '${rule.passScore}점 이상 합격',
          '문항당 ${rule.pointsPerQuestion}점, ${rule.maxScore}점 만점',
        ),
        _row(
          colors.wrong,
          CupertinoIcons.exclamationmark_triangle,
          '과목별 과락',
          '$failSummary 미만이면 총점과 상관없이 불합격',
        ),
        if (isDetailed) ...[
          _row(
            colors.warning,
            CupertinoIcons.paperplane,
            '시간이 끝나면 자동 제출',
            '남은 시간은 서버 기준이라 기기 시각을 바꿔도 같아요',
          ),
          _row(
            colors.accent,
            CupertinoIcons.arrow_clockwise,
            '나갔다 와도 이어서 풀어요',
            '답은 고를 때마다 저장되고, 시간은 계속 흘러요',
          ),
          _row(
            colors.iconSecondary,
            CupertinoIcons.eye_slash,
            '풀이 중엔 정답·해설·SQL 실행이 없어요',
            '실제 시험처럼 머릿속으로 풀어요',
          ),
        ],
      ],
    );
  }

  Widget _row(Color color, IconData icon, String title, String subtitle) =>
      PassqlListRow(
        title: title,
        subtitle: subtitle,
        leading: PassqlIconTile(icon: icon, color: color),
      );
}
