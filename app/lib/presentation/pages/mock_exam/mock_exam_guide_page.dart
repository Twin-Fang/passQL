import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';
import '../../providers/mock_exam_providers.dart';
import '../../widgets/common/app_toast.dart';
import '../../widgets/mock_exam/mock_exam_rule_rows.dart';
import '../../widgets/pro/pro_access_feedback.dart';
import '../../widgets/pro/pro_offer_sheet.dart';

/// 시험 안내 (#866): 형식·합격 기준·과락·자동 제출·이어 풀기·풀이 중 정답 없음 > 시작 확인 > 풀이
/// 무료 체험 회차면 "체험 1회" 안내. 시작 판정은 서버 (거부되면 이용권 안내·문구)
class MockExamGuidePage extends ConsumerStatefulWidget {
  const MockExamGuidePage({super.key, required this.roundUuid});

  final String roundUuid;

  @override
  ConsumerState<MockExamGuidePage> createState() => _MockExamGuidePageState();
}

class _MockExamGuidePageState extends ConsumerState<MockExamGuidePage> {
  bool _isStarting = false;

  Future<void> _confirmAndStart(int durationMinutes) async {
    final isConfirmed = await showPassqlConfirmDialog(
      context,
      title: '시험을 시작할까요?',
      message: '시작하면 $durationMinutes분 타이머가 바로 돌아가요.',
      confirmLabel: '시작',
      isDestructive: false,
    );
    if (!isConfirmed || !mounted) return;
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
                          '조용한 곳에서 한 번에 풀어 보세요. 결과에서 과목별 점수와 과락을 바로 알려 드려요.',
                          style: PassqlTypography.subheadline.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: PassqlSpacing.lg),
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
                              '무료 체험은 1회예요. 점수와 합격 여부는 바로 보이고, 과목별 분석과 문항 해설은 이용권으로 열려요.',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PassqlBottomActionBar(
                    actions: [
                      PassqlButton(
                        label: '시작하기',
                        isLoading: _isStarting,
                        onPressed: () => _confirmAndStart(
                          roundList.examRule.durationMinutes,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
