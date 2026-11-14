import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../data/models/exam_answer/exam_answer_round_response.dart';
import '../../design/design.dart';
import '../../providers/exam_answer_providers.dart';
import '../../widgets/exam_answer/exam_answer_key_tab.dart';
import '../../widgets/exam_answer/exam_answer_my_score_tab.dart';
import '../../widgets/exam_answer/exam_answer_round_summary.dart';

/// 화면 탭 2개: 내 가채점, 가답안
enum _ExamAnswerTab { myScore, answerKey }

/// 회차별 가답안·OMR 가채점 (#1075): 회차 요약 > 탭 [내 가채점 | 가답안]
/// 내 가채점 입력 중에는 하단 바에 채점 버튼 (오류 문구 포함)
class ExamAnswerPage extends ConsumerStatefulWidget {
  const ExamAnswerPage({
    super.key,
    required this.certType,
    required this.roundNumber,
  });

  final String certType;
  final int roundNumber;

  @override
  ConsumerState<ExamAnswerPage> createState() => _ExamAnswerPageState();
}

class _ExamAnswerPageState extends ConsumerState<ExamAnswerPage> {
  _ExamAnswerTab _selectedTab = _ExamAnswerTab.myScore;

  ExamAnswerRoundKey get _roundKey =>
      (certType: widget.certType, roundNumber: widget.roundNumber);

  @override
  Widget build(BuildContext context) {
    final roundAsync = ref.watch(examAnswerRoundProvider(_roundKey));
    final roundResponse = roundAsync.valueOrNull;
    return Scaffold(
      appBar: const PassqlNavBar(
        title: '가답안과 가채점',
        leading: PassqlNavLeading.back,
      ),
      body: roundResponse != null
          ? _buildContent(roundResponse)
          : roundAsync.hasError
          ? _buildError(roundAsync.error!)
          : const PassqlStatusView.loading(),
      bottomNavigationBar: roundResponse != null ? _buildGradeBar() : null,
    );
  }

  /// 회차 조회 실패: 없는 회차(404)는 빈 상태, 그 외는 다시 시도
  Widget _buildError(Object error) {
    final appException = error.asAppException;
    if (appException.code == ErrorCode.notFound) {
      return PassqlStatusView.empty(
        icon: CupertinoIcons.doc_text_search,
        title: '아직 가답안이 없어요',
        message: '시험이 끝나면 가답안과 가채점이 열려요',
      );
    }
    return PassqlStatusView.error(
      message: appException.message,
      onRetry: () => ref.invalidate(examAnswerRoundProvider(_roundKey)),
    );
  }

  Widget _buildContent(ExamAnswerRoundResponse roundResponse) {
    final sheetState = ref.watch(examAnswerSheetProvider(_roundKey));
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        PassqlRefreshControl(
          onRefresh: () async {
            ref.invalidate(examAnswerRoundProvider(_roundKey));
            await ref.read(examAnswerRoundProvider(_roundKey).future);
          },
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            PassqlSpacing.md,
            PassqlSpacing.xs,
            PassqlSpacing.md,
            PassqlSpacing.lg,
          ),
          sliver: SliverList.list(
            children: [
              ExamAnswerRoundSummary(roundResponse: roundResponse),
              const SizedBox(height: PassqlSpacing.lg),
              PassqlSegmentedControl<_ExamAnswerTab>(
                segments: const [
                  PassqlSegment(value: _ExamAnswerTab.myScore, label: '내 가채점'),
                  PassqlSegment(value: _ExamAnswerTab.answerKey, label: '가답안'),
                ],
                selectedValue: _selectedTab,
                onSelected: (tab) => setState(() => _selectedTab = tab),
              ),
              const SizedBox(height: PassqlSpacing.lg),
              PassqlFadeSwitcher(
                child: _selectedTab == _ExamAnswerTab.myScore
                    ? ExamAnswerMyScoreTab(
                        key: const ValueKey(_ExamAnswerTab.myScore),
                        roundKey: _roundKey,
                        roundResponse: roundResponse,
                      )
                    : ExamAnswerKeyTab(
                        key: const ValueKey(_ExamAnswerTab.answerKey),
                        items: roundResponse.items,
                        gradingRule: roundResponse.effectiveGradingRule,
                        myAnswers: sheetState.gradedSheet?.answers,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 채점 바: 내 가채점 입력 중일 때만 (오류 문구 > 채점 버튼)
  Widget? _buildGradeBar() {
    if (_selectedTab != _ExamAnswerTab.myScore) return null;
    final sheetState = ref.watch(examAnswerSheetProvider(_roundKey));
    if (!sheetState.isLoaded || !sheetState.isEditing) return null;
    final colors = context.passqlColors;
    final gradingError = sheetState.gradingError;
    final remainingCount = sheetState.answers.length - sheetState.enteredCount;
    return PassqlBottomActionBar(
      top: gradingError == null
          ? null
          : Text(
              gradingError.message,
              textAlign: TextAlign.center,
              style: PassqlTypography.footnote.copyWith(
                color: colors.wrongText,
              ),
            ),
      actions: [
        PassqlButton(
          label: remainingCount == 0
              ? '채점하기'
              : '채점하기 (남은 $remainingCount문항은 모름)',
          isLoading: sheetState.isGrading,
          onPressed: sheetState.enteredCount == 0
              ? null
              : ref.read(examAnswerSheetProvider(_roundKey).notifier).grade,
        ),
      ],
    );
  }
}
