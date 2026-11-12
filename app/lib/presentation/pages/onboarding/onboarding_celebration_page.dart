import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../design/design.dart';

/// 축하 화면 이동 인자: 첫 문제가 마지막이었는지 + 오늘 세트 문제 수
typedef OnboardingCelebrationArguments = ({
  bool isLastQuestion,
  int setQuestionCount,
});

/// 첫 문제 실행 결과처럼 보이는 SQL 문 (#999)
const _firstSolveQuery = 'UPDATE 수험생\nSET 푼_문제 = 1;';
const _firstSolveStatusText = '1행 수정됨';

/// 온보딩에서 들어온 첫 문제 [다음] 뒤 축하 화면. 정답·오답과 관계없이 같은 화면이다.
/// 제목 > UPDATE 한 줄·1행 수정됨 > 오늘의 세트 진행(1/N 차오름) > 남은 문제 안내 (#999)
/// 닫히면(버튼·뒤로가기) 풀이 화면이 이어서 다음 문제 또는 결과로 간다.
class OnboardingCelebrationPage extends StatelessWidget {
  const OnboardingCelebrationPage({
    super.key,
    required this.isLastQuestion,
    required this.setQuestionCount,
  });

  /// 세트가 1문제뿐이라 첫 문제가 마지막이었는지 (버튼 문구만 다름)
  final bool isLastQuestion;

  /// 오늘 세트 문제 수 (진행 바 1/N)
  final int setQuestionCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final questionCount = setQuestionCount < 1 ? 1 : setQuestionCount;
    final remainingCount = questionCount - 1;
    return Scaffold(
      appBar: const PassqlNavBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PassqlReveal(
                child: Semantics(
                  header: true,
                  child: Text(
                    '첫 문제 완료!',
                    textAlign: TextAlign.center,
                    style: PassqlTypography.title1.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PassqlSpacing.lg),
              // 실행 > 한 박자 뒤 결과 줄
              PassqlReveal(
                index: 1,
                child: PassqlCard(
                  isCardTapExposedToScreenReader: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PassqlCodeBlock(
                        code: _firstSolveQuery,
                        isSelectable: false,
                        highlightedKeywords: PassqlCodeBlock.sqlKeywords,
                      ),
                      const SizedBox(height: PassqlSpacing.sm),
                      const PassqlReveal(
                        delay: PassqlMotion.onboardingSceneStep,
                        child: PassqlQueryStatusLine(
                          text: _firstSolveStatusText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: PassqlSpacing.lg),
              PassqlReveal(
                index: 2,
                delay: PassqlMotion.onboardingSceneStep,
                child: _TodaySetProgress(questionCount: questionCount),
              ),
              const SizedBox(height: PassqlSpacing.md),
              PassqlReveal(
                index: 4,
                delay: PassqlMotion.onboardingSceneStep,
                child: PassqlKeepAllText(
                  remainingCount > 0
                      ? '남은 $remainingCount문제도 이어서 풀어 봐요'
                      : '오늘의 세트를 다 풀었어요',
                  textAlign: TextAlign.center,
                  style: PassqlTypography.callout.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PassqlBottomActionBar(
        hasTopHairline: false,
        actions: [
          PassqlButton(
            label: isLastQuestion ? '결과 보기' : '이어서 풀기',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}

/// 오늘의 세트 진행: 이름 | 1 / N > 막대 (등장 뒤 0 > 1/N 차오름, 동작 줄이기면 바로)
class _TodaySetProgress extends StatefulWidget {
  const _TodaySetProgress({required this.questionCount});

  final int questionCount;

  @override
  State<_TodaySetProgress> createState() => _TodaySetProgressState();
}

class _TodaySetProgressState extends State<_TodaySetProgress> {
  Timer? _fillTimer;
  bool _isFilled = false;
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (PassqlMotion.isReduced(context)) {
      _isFilled = true;
      return;
    }
    // 진행 묶음이 보인 다음 차오름
    _fillTimer = Timer(PassqlMotion.onboardingSceneStep * 2, () {
      if (mounted) setState(() => _isFilled = true);
    });
  }

  @override
  void dispose() {
    _fillTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final labelStyle = PassqlTypography.footnoteSemibold.copyWith(
      color: colors.secondaryLabel,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('오늘의 세트', style: labelStyle)),
            Text(
              '1 / ${widget.questionCount}',
              style: labelStyle.copyWith(
                fontFeatures: PassqlTypography.tabular,
              ),
            ),
          ],
        ),
        const SizedBox(height: PassqlSpacing.xs),
        PassqlProgressBar(value: _isFilled ? 1 / widget.questionCount : 0),
      ],
    );
  }
}
