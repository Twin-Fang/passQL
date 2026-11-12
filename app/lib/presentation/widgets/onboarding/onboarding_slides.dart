import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/exam_dday.dart';
import '../../../data/models/ai/choice_explanation.dart';
import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/choice_explanation_providers.dart';
import '../../providers/home_providers.dart';
import '../ai_explanation/ai_explanation_sections.dart';
import '../question/execute_result_card.dart';
import 'onboarding_run_reveal.dart';
import 'onboarding_slide.dart';
import 'onboarding_sql_card.dart';

/// 온보딩 4장: INSERT(환영) > SELECT(직접 실행) > EXPLAIN(AI 해설) > 5문제 실력 확인
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
      // 닉네임을 알면 이름을 불러 줌 (아직 모르면 이름 없이)
      title: nickname.isEmpty
          ? '반가워요,\nSQLD 합격까지 함께해요'
          : '$nickname님,\nSQLD 합격까지 함께해요',
      subtitle: '실제 SQL을 실행하며 감을 익혀요.',
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
          // 실행 중 > 실행 결과 (A 먼저, B 는 한 박자 뒤)
          OnboardingRunReveal(
            startDelay: PassqlMotion.onboardingSceneStep,
            child: ExecuteResultCard(
              result: _successResult,
              executedChoiceLabel: 'A',
              margin: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          const PassqlCodeBlock(
            code: 'SELECT ENAME FROM EMP\nHAVING SAL >= 3000;',
            isSelectable: false,
          ),
          OnboardingRunReveal(
            startDelay:
                PassqlMotion.onboardingSceneStep * 2 +
                PassqlMotion.onboardingRunDuration,
            child: ExecuteResultCard(
              result: _errorResult,
              executedChoiceLabel: 'B',
              margin: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3장: 틀린 이유를 AI 가 바로 설명 (실제 결과 화면의 구조화 해설 부품 그대로, 2장 A·B 보기 이어서)
class _ExplainSlide extends StatelessWidget {
  const _ExplainSlide();

  // 예시 보기 키 (2장 A: WHERE 성공, B: HAVING 오류), 화면 라벨도 같은 글자
  static const _whereChoiceKey = 'A';
  static const _havingChoiceKey = 'B';

  // 서버 호출 없는 고정 해설 > 요청 키는 자리 값
  static const _sampleEntry = AiExplanationEntry(
    request: ChoiceExplanationRequest(
      questionUuid: 'onboarding-sample',
      choiceSetUuid: 'onboarding-sample',
      selectedChoiceKey: _havingChoiceKey,
    ),
    isCorrect: false,
    displayLabelByChoiceKey: {
      _whereChoiceKey: _whereChoiceKey,
      _havingChoiceKey: _havingChoiceKey,
    },
    correctChoiceKey: _whereChoiceKey,
  );

  // 섹션 3개: 판정·시험 팁·보기별 판단 (작은 화면은 시험 팁 생략)
  static const _sampleExplanation = ChoiceExplanation(
    selectedChoiceKey: _havingChoiceKey,
    correctChoiceKey: _whereChoiceKey,
    examTip: '집계 조건은 HAVING, 행 조건은 WHERE',
    choiceAnalyses: [
      ChoiceAnalysis(
        choiceKey: _whereChoiceKey,
        isCorrect: true,
        reason: '행 조건이라 `WHERE`로 걸러요.',
      ),
      ChoiceAnalysis(
        choiceKey: _havingChoiceKey,
        reason: '`HAVING`은 그룹 조건 전용이에요.',
      ),
    ],
  );

  // 시험 팁까지 들어가는 화면 높이 (SE 667 은 생략, mini 812 이상은 표시)
  static const double _examTipMinimumScreenHeight = 760;

  @override
  Widget build(BuildContext context) {
    final hasRoomForExamTip =
        MediaQuery.sizeOf(context).height >= _examTipMinimumScreenHeight;
    return OnboardingSlide(
      title: '틀려도 괜찮아요,\n이유를 바로 알려 줘요',
      subtitle: '틀린 문제는 오답 노트에 모아 둬요.',
      visual: Center(
        child: PassqlCard(
          isCardTapExposedToScreenReader: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PassqlAiHeader(title: 'AI 해설'),
              const SizedBox(height: PassqlSpacing.sm),
              // 실제 해설처럼: 글 줄 스켈레톤 잠깐 > 판정 줄 단어 등장 > 섹션 차례로 (동작 줄이기면 바로 최종)
              OnboardingRunReveal(
                loadingPlaceholder: const PassqlTextSkeleton(lineCount: 4),
                child: AiExplanationSections(
                  explanation: hasRoomForExamTip
                      ? _sampleExplanation
                      : _sampleExplanation.copyWith(examTip: ''),
                  entry: _sampleEntry,
                  isVerdictAnimated: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4장: 5문제 실력 확인 안내 (#975): 미리보기 카드(문제 5칸 > 안내 세 줄) + 시험 D-day
class _CommitSlide extends ConsumerWidget {
  const _CommitSlide();

  // 실력 확인 문제 수 (오늘의 세트 하루 상한과 같은 값, 서버 AdminDailyChallengeService)
  static const int _questionCount = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final examDate = ref.watch(
      homeOverviewProvider.select(
        (overview) => overview.valueOrNull?.examSchedule?.examDate,
      ),
    );
    final remainingDays = examDate == null ? null : daysUntilExam(examDate);
    return OnboardingSlide(
      title: '$_questionCount문제로\n지금 실력부터 확인해요',
      // 세트 문제는 같지만 순서는 회원마다 달라서, 같은 문제라는 단정 대신 순위 경쟁을 알린다
      subtitle: '오늘의 세트는 매일 새로 열리고 순위도 겨뤄요.',
      visual: Center(
        child: PassqlCard(
          isCardTapExposedToScreenReader: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '오늘의 세트',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.label,
                      ),
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
              const SizedBox(height: PassqlSpacing.md),
              const _QuestionSteps(count: _questionCount),
              const SizedBox(height: PassqlSpacing.md),
              const _CheckLine(
                icon: CupertinoIcons.timer,
                text: '$_questionCount문제, 금방 끝나요',
              ),
              const _CheckLine(
                icon: CupertinoIcons.bolt_fill,
                text: '크레딧을 쓰지 않아요',
              ),
              const _CheckLine(
                icon: CupertinoIcons.chart_bar_fill,
                text: '끝나면 합격 준비도가 채워져요',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 문제 칸 줄: 번호 원 N개를 선으로 이음 (첫 칸만 강조색 = 지금 시작할 문제)
class _QuestionSteps extends StatelessWidget {
  const _QuestionSteps({required this.count});

  final int count;

  // 번호 원 지름, 잇는 선 두께
  static const double _stepSize = 36;
  static const double _connectorHeight = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return ExcludeSemantics(
      child: Row(
        children: [
          for (var index = 0; index < count; index++) ...[
            if (index > 0)
              Expanded(
                child: Container(
                  height: _connectorHeight,
                  color: colors.separator,
                ),
              ),
            Container(
              width: _stepSize,
              height: _stepSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: index == 0 ? colors.accent : colors.fill,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: index == 0 ? colors.onAccent : colors.secondaryLabel,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 안내 한 줄: 강조색 아이콘 + 문장
class _CheckLine extends StatelessWidget {
  const _CheckLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
      child: Row(
        children: [
          Icon(icon, size: PassqlIconSize.md, color: colors.accent),
          const SizedBox(width: PassqlSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: PassqlTypography.subheadline.copyWith(color: colors.label),
            ),
          ),
        ],
      ),
    );
  }
}
