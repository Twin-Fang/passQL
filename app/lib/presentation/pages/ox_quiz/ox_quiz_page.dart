import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../design/design.dart';
import '../../providers/ox_quiz_session_notifier.dart';
import '../../providers/ox_quiz_session_state.dart';
import '../../widgets/ox_quiz/ox_quiz_card_view.dart';
import '../../widgets/ox_quiz/ox_quiz_progress_header.dart';
import '../../widgets/ox_quiz/ox_quiz_summary_view.dart';

/// OX 퀴즈 화면 (#1083): 오늘 목표 막대·콤보 > 카드 1장씩(O·X 큰 버튼, 바로 해설) > 끝나면 요약
/// 문제 탭 OX 퀴즈 행에서 진입, 카드는 개념 바로 확인 문장 (무료는 무료 단원만)
class OxQuizPage extends ConsumerWidget {
  const OxQuizPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(oxQuizSessionProvider);
    return Scaffold(
      appBar: PassqlNavBar(title: 'OX 퀴즈', leading: PassqlNavLeading.back),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.xl,
          ),
          // 로딩 스켈레톤 > 카드·요약·빈·오류 페이드 교체
          child: PassqlFadeSwitcher(
            child: sessionAsync.when(
              loading: () => const PassqlListSkeleton(key: ValueKey('loading')),
              error: (error, _) => KeyedSubtree(
                key: const ValueKey('error'),
                child: PassqlStatusView.error(
                  message: error.asAppException.message,
                  onRetry: () => ref.invalidate(oxQuizSessionProvider),
                ),
              ),
              data: (session) => KeyedSubtree(
                key: ValueKey(_contentKeyOf(session)),
                child: _OxQuizContent(session: session),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 화면 단위 전환 키: 빈 묶음 / 요약 / 카드 (카드 사이도 페이드)
  static String _contentKeyOf(OxQuizSessionState session) {
    if (session.cards.isEmpty) return 'empty';
    if (session.isFinished) return 'summary';
    return 'card-${session.currentIndex}';
  }
}

/// 묶음 상태별 내용: 빈 묶음 안내 / 요약 / 진행 머리 + 카드
class _OxQuizContent extends ConsumerWidget {
  const _OxQuizContent({required this.session});

  final OxQuizSessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionNotifier = ref.read(oxQuizSessionProvider.notifier);
    if (session.cards.isEmpty) {
      return PassqlStatusView.empty(
        icon: CupertinoIcons.checkmark_seal,
        title: '지금 풀 카드가 없어요',
        message: session.hasLockedTopics
            ? '이용권이 있으면 모든 단원 카드를 풀 수 있어요'
            : '맞힌 카드는 복습일이 되면 다시 나와요',
      );
    }
    final currentCard = session.currentCard;
    if (currentCard == null) {
      return OxQuizSummaryView(
        session: session,
        onRestartPressed: sessionNotifier.restart,
        onClosePressed: () => context.pop(),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OxQuizProgressHeader(
          todayAnsweredCount: session.todayAnsweredCount,
          dailyGoalCount: session.dailyGoalCount,
          cardNumber: session.currentIndex + 1,
          cardCount: session.cards.length,
          comboCount: session.comboCount,
        ),
        const SizedBox(height: PassqlSpacing.lg),
        OxQuizCardView(
          card: currentCard,
          pickedIsTrue: session.pickedIsTrue,
          isLastCard: session.currentIndex == session.cards.length - 1,
          onPicked: (isTrue) {
            sessionNotifier.pick(isTrue);
            PassqlHaptics.playAnswerResult(
              isCorrect: isTrue == currentCard.isTrue,
            );
          },
          onNextPressed: sessionNotifier.moveToNextCard,
        ),
      ],
    );
  }
}
