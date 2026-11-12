import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../data/models/mock_exam/mock_exam_enums.dart';
import '../../../data/models/mock_exam/mock_exam_round_list.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_countdown.dart';
import '../../providers/mock_exam_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/mock_exam/mock_exam_rule_rows.dart';
import '../../widgets/pro/pro_access_feedback.dart';
import '../../widgets/pro/pro_offer_sheet.dart';

/// 시험 안내 (#866): 형식·합격 기준·과락·자동 제출·이어 풀기·풀이 중 정답 없음 > 시작 확인 > 풀이
/// 풀이 중 회차면 남은 시간·답한 문항 안내 > 확인 없이 이어 풀기 (#902)
/// 무료 체험 회차면 "체험 1회" 안내. 시작 판정은 서버 (거부되면 이용권 안내·문구)
class MockExamGuidePage extends ConsumerStatefulWidget {
  const MockExamGuidePage({super.key, required this.roundUuid});

  final String roundUuid;

  @override
  ConsumerState<MockExamGuidePage> createState() => _MockExamGuidePageState();
}

class _MockExamGuidePageState extends ConsumerState<MockExamGuidePage> {
  bool _isStarting = false;

  /// 시작(확인 창 > 시작) 또는 이어 풀기(확인 없이) > 풀이 화면
  Future<void> _startOrResume({
    required int durationMinutes,
    required bool isResuming,
  }) async {
    if (!isResuming) {
      final isConfirmed = await showPassqlConfirmDialog(
        context,
        title: '시험을 시작할까요?',
        message: '시작하면 $durationMinutes분 타이머가 바로 돌아가요.',
        confirmLabel: '시작',
        isDestructive: false,
      );
      if (!isConfirmed || !mounted) return;
    }
    setState(() => _isStarting = true);
    try {
      final attemptUuid = await startOrResumeMockExam(ref, widget.roundUuid);
      if (!mounted) return;
      context.pushReplacement(AppRoutes.mockExamAttempt(attemptUuid));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isStarting = false);
      final exception = error.asAppException;
      if (exception.code == ErrorCode.mockExamFreeTrialUsed) {
        showProOfferSheet(context, ref);
        return;
      }
      final feedbackResult = await showProAccessFeedback(context, ref, error);
      if (feedbackResult == ProAccessFeedbackResult.notHandled && mounted) {
        showAppToast(context, exception.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final roundList = ref.watch(mockExamRoundsProvider).valueOrNull;
    final round = roundList?.rounds
        .where((round) => round.roundUuid == widget.roundUuid)
        .firstOrNull;
    final resumableAttempt = _resumableAttemptOf(roundList, round);
    final isResuming = resumableAttempt != null;
    return Scaffold(
      appBar: PassqlNavBar(
        title: round?.title ?? '모의고사',
        leading: PassqlNavLeading.back,
      ),
      body: SafeArea(
        child: roundList == null
            ? const PassqlStatusView.loading()
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        PassqlSpacing.md,
                        PassqlSpacing.xs,
                        PassqlSpacing.md,
                        PassqlSpacing.xl,
                      ),
                      children: [
                        Text(
                          '실제 SQLD와 같은 형식이에요',
                          style: PassqlTypography.title2.copyWith(
                            color: colors.label,
                          ),
                        ),
                        const SizedBox(height: PassqlSpacing.xs),
                        Text(
                          '조용한 곳에서 한 번에 풀어 보세요. 결과에서 점수와 합격·과락을 바로 알려 드려요.',
                          style: PassqlTypography.subheadline.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: PassqlSpacing.lg),
                        if (resumableAttempt != null) ...[
                          _ResumeNotice(attempt: resumableAttempt),
                          const SizedBox(height: PassqlSpacing.lg),
                        ],
                        MockExamRuleRows(
                          rule: roundList.examRule,
                          isDetailed: true,
                        ),
                        if (round != null &&
                            round.isFreeTrialRound &&
                            round.lastAttempt == null) ...[
                          const SizedBox(height: PassqlSpacing.lg),
                          const PassqlCallout(
                            kind: PassqlCalloutKind.accent,
                            icon: CupertinoIcons.gift,
                            label: '무료 체험',
                            child: Text(
                              '무료 체험은 1회예요. 점수와 합격 여부는 바로 보이고, 과목별 분석과 문항 해설은 PRO로 볼 수 있어요.',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PassqlBottomActionBar(
                    actions: [
                      PassqlButton(
                        label: isResuming ? '이어서 풀기' : '시작하기',
                        isLoading: _isStarting,
                        onPressed: () => _startOrResume(
                          durationMinutes: roundList.examRule.durationMinutes,
                          isResuming: isResuming,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  /// 이 회차의 풀이 중 응시 (회차 목록 응답의 풀이 중 응시, 없으면 null)
  static MockExamInProgressAttempt? _resumableAttemptOf(
    MockExamRoundListResponse? roundList,
    MockExamRoundSummary? round,
  ) {
    final inProgressAttempt = roundList?.inProgressAttempt;
    final isRoundInProgress =
        round?.lastAttempt?.status == MockExamAttemptStatus.inProgress;
    if (inProgressAttempt == null || !isRoundInProgress) return null;
    return inProgressAttempt.roundUuid == round!.roundUuid
        ? inProgressAttempt
        : null;
  }
}

/// 풀이 중 안내: 남은 시간(목록을 받은 시점 서버 기준)·답한 문항 수
class _ResumeNotice extends StatelessWidget {
  const _ResumeNotice({required this.attempt});

  final MockExamInProgressAttempt attempt;

  @override
  Widget build(BuildContext context) {
    return PassqlCallout(
      kind: PassqlCalloutKind.accent,
      icon: CupertinoIcons.timer,
      label: '풀이 중',
      child: Text(
        '남은 시간 ${formatMockExamRemaining(attempt.remainingSeconds)}, '
        '답한 문항 ${attempt.answeredCount}개예요. 이어서 풀면 남은 시간부터 계속돼요.',
      ),
    );
  }
}
