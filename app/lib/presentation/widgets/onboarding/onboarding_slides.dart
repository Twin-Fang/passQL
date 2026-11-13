import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/ai/choice_explanation.dart';
import '../../../data/models/question/execute_result.dart';
import '../../design/design.dart';
import '../../providers/ai_explanation_session_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/choice_explanation_providers.dart';
import '../ai_explanation/ai_explanation_sections.dart';
import '../question/execute_result_card.dart';
import 'onboarding_feature_grid.dart';
import 'onboarding_run_reveal.dart';
import 'onboarding_slide.dart';
import 'onboarding_sql_card.dart';

/// 온보딩 3장 (#945): INSERT(환영) > 실행과 AI 해설 > 기능 한눈에
/// 예시 SQL·결과·해설은 고정 값 (서버 호출 없음)
const List<Widget> onboardingSlides = [
  _InsertSlide(),
  _RunAndExplainSlide(),
  _FeatureOverviewSlide(),
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
      subtitle: '책 없이, 앱 하나로 준비해요.',
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

/// 2장: 보기 실행 > 오류 > AI 해설 (실제 풀이 화면의 실행 결과 카드, 결과 화면의 구조화 해설 부품 그대로)
class _RunAndExplainSlide extends StatelessWidget {
  const _RunAndExplainSlide();

  // 예시 보기 키 (A: WHERE 정답, B: HAVING 오류), 화면 라벨도 같은 글자
  static const _whereChoiceKey = 'A';
  static const _havingChoiceKey = 'B';

  static const _havingErrorResult = ExecuteResult(
    errorCode: 'SQL_ERROR',
    errorMessage: 'column "ename" must appear in the GROUP BY clause',
  );

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

  // 섹션 2개: 판정, 보기별 판단 (실행 카드와 한 장에 들어가게 시험 팁 생략)
  static const _sampleExplanation = ChoiceExplanation(
    selectedChoiceKey: _havingChoiceKey,
    correctChoiceKey: _whereChoiceKey,
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

  // 연출 순서: 실행 시작 > 오류 결과 > 해설 카드 등장 > 해설 스켈레톤 > 해설
  static const _runStartDelay = PassqlMotion.onboardingSceneStep;
  static final _explanationStartDelay =
      PassqlMotion.onboardingSceneStep + PassqlMotion.onboardingRunDuration;

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      title: '실행해 보고,\n이유까지 바로 알아요',
      subtitle: '보기 SQL을 돌려 보고 틀린 이유는 AI 해설로.',
      visual: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PassqlCodeBlock(
            code: 'SELECT ENAME FROM EMP\nHAVING SAL >= 3000;',
            isSelectable: false,
          ),
          OnboardingRunReveal(
            startDelay: _runStartDelay,
            child: ExecuteResultCard(
              result: _havingErrorResult,
              executedChoiceLabel: _havingChoiceKey,
              margin: const EdgeInsets.symmetric(vertical: PassqlSpacing.xs),
            ),
          ),
          PassqlReveal(
            delay: _explanationStartDelay,
            child: PassqlCard(
              isCardTapExposedToScreenReader: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PassqlAiHeader(title: 'AI 해설'),
                  const SizedBox(height: PassqlSpacing.sm),
                  // 실제 해설처럼: 글 줄 스켈레톤 잠깐 > 판정 줄 단어 등장 > 섹션 차례로 (동작 줄이기면 바로 최종)
                  OnboardingRunReveal(
                    startDelay: _explanationStartDelay,
                    loadingPlaceholder: const PassqlTextSkeleton(lineCount: 3),
                    child: const AiExplanationSections(
                      explanation: _sampleExplanation,
                      entry: _sampleEntry,
                      isVerdictAnimated: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3장: 기능 한눈에 > 오늘의 세트로 시작 (버튼은 OnboardingPage 의 첫 문제 풀기)
class _FeatureOverviewSlide extends StatelessWidget {
  const _FeatureOverviewSlide();

  @override
  Widget build(BuildContext context) {
    return const OnboardingSlide(
      title: '필요한 건\n다 여기 있어요',
      subtitle: '먼저 오늘의 세트 5문제로 시작해요.',
      visual: OnboardingFeatureGrid(),
    );
  }
}
