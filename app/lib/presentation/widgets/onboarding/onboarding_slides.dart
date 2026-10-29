import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/exam_dday.dart';
import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_providers.dart';
import '../question/execute_result_card.dart';
import 'onboarding_keyword_stickers.dart';
import 'onboarding_slide.dart';
import 'onboarding_sql_card.dart';

/// 온보딩 4장: INSERT(환영) > SELECT(직접 실행) > EXPLAIN(AI 해설) > COMMIT(매일 약속)
/// 예시 SQL·결과·해설은 고정 값이다 (서버 호출 없음).
const List<Widget> onboardingSlides = [
  _InsertSlide(),
  _SelectSlide(),
  _ExplainSlide(),
  _CommitSlide(),
];

/// 1장: 가입 = 수험생 테이블에 내 행이 추가됨
class _InsertSlide extends ConsumerWidget {
  const _InsertSlide();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(
      authProvider.select((session) => session.valueOrNull?.nickname ?? ''),
    );
    return OnboardingSlide(
      title: '환영해요,\n방금 1행이 추가됐어요',
      subtitle: 'passQL에서 SQLD 합격까지 함께해요.',
      visual: Center(
        child: OnboardingSqlCard(
          code: "INSERT INTO 수험생\nVALUES ('$nickname');",
          statusLabel: '1행 추가됨',
          columns: const ['#', '닉네임', '상태'],
          rows: [
            const ['…', '…', '…'],
            ['NEW', nickname, '합격 준비중'],
          ],
          highlightedRowIndex: 1,
        ),
      ),
    );
  }
}

/// 2장: 보기를 실행해 결과를 비교 (실제 풀이 화면의 실행 결과 카드 그대로)
class _SelectSlide extends StatelessWidget {
  const _SelectSlide();

  static const _successResult = ExecuteResult(
    columns: ['ENAME'],
    rows: [
      ['KING'],
      ['FORD'],
      ['SCOTT'],
    ],
    rowCount: 3,
    elapsedMs: 12,
  );
  static const _errorResult = ExecuteResult(
    errorCode: 'SQL_ERROR',
    errorMessage: 'column "ename" must appear in the GROUP BY clause',
  );

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      title: '보기를 직접\n실행해 볼 수 있어요',
      subtitle: '결과를 눈으로 비교하면 답이 보여요.',
      visual: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PassqlCodeBlock(
                code: 'SELECT ENAME FROM EMP\nWHERE SAL >= 3000;',
                isSelectable: false,
              ),
              ExecuteResultCard(
                result: _successResult,
                executedChoiceLabel: 'A',
                margin: const EdgeInsets.symmetric(
                  vertical: PassqlSpacing.xs,
                ),
              ),
              const SizedBox(height: PassqlSpacing.xs),
              const PassqlCodeBlock(
                code: 'SELECT ENAME FROM EMP\nHAVING SAL >= 3000;',
                isSelectable: false,
              ),
              ExecuteResultCard(
                result: _errorResult,
                executedChoiceLabel: 'B',
                margin: const EdgeInsets.symmetric(
                  vertical: PassqlSpacing.xs,
                ),
              ),
            ],
          ),
    );
  }
}

/// 3장: 틀린 이유를 AI 가 바로 설명
class _ExplainSlide extends StatelessWidget {
  const _ExplainSlide();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final bodyStyle = PassqlTypography.explanationBody.copyWith(
      color: colors.label,
    );
    final emphasisStyle = PassqlTypography.explanationEmphasis.copyWith(
      color: colors.label,
    );
    return OnboardingSlide(
      title: '틀려도 괜찮아요,\n이유를 바로 알려 줘요',
      subtitle: '틀린 문제는 오답 노트에 모아 둬요.',
      visual: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PassqlCodeBlock(code: 'EXPLAIN 내_오답;', isSelectable: false),
            const SizedBox(height: PassqlSpacing.sm),
            PassqlCard(
              isCardTapExposedToScreenReader: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PassqlAiHeader(title: 'AI 해설'),
                  const SizedBox(height: PassqlSpacing.xs),
                  Text.rich(
                    TextSpan(
                      style: bodyStyle,
                      children: [
                        TextSpan(text: 'HAVING', style: emphasisStyle),
                        const TextSpan(text: '은 GROUP BY로 묶은 결과를 거를 때 써요. '),
                        const TextSpan(text: '묶지 않은 행을 거르려면 '),
                        TextSpan(text: 'WHERE', style: emphasisStyle),
                        const TextSpan(text: '를 써야 해요.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.sm),
                  const PassqlTextSkeleton(lineCount: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4장: 하루 5문제 약속 + 키워드 스티커 + 시험 D-day
class _CommitSlide extends ConsumerWidget {
  const _CommitSlide();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examDate = ref.watch(
      homeOverviewProvider.select(
        (overview) => overview.valueOrNull?.examSchedule?.examDate,
      ),
    );
    final remainingDays = examDate == null ? null : daysUntilExam(examDate);
    return OnboardingSlide(
      title: '하루 5문제,\n오늘부터 커밋해요',
      // 세트 문제는 같지만 순서는 회원마다 달라서, 같은 문제라는 단정 대신 순위 경쟁을 알린다
      subtitle: '오늘의 세트를 풀고 순위를 겨뤄요.',
      backdrop: const OnboardingKeywordStickers(stickers: commitStickers),
      visual: Center(
        child: PassqlCard(
          isCardTapExposedToScreenReader: false,
          child: Row(
            children: [
              const Expanded(
                child: PassqlCodeBlock(
                  code: 'COMMIT; -- 매일 5문제',
                  isSelectable: false,
                  hasBackground: false,
                ),
              ),
              // 지난 시험이거나 일정을 모르면 숨김 (지난 날짜로 약속하지 않는다)
              if (remainingDays != null && remainingDays >= 0)
                PassqlBadge(
                  text: examDdayLabel(remainingDays),
                  kind: PassqlBadgeKind.warning,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
