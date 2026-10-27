import 'package:flutter/cupertino.dart';

import '../../../data/models/exam_trend/exam_trend_report_response.dart';
import '../../design/design.dart';
import '../exam_trend/exam_trend_pattern_card.dart';

/// 한 페이지가 차지하는 폭 비율: 다음 카드가 오른쪽에 살짝 보여 넘길 수 있음을 알림
const double _pageViewportFraction = 0.9;

/// 홈 출제 경향 섹션: 머리(제목 + '최신 기출 반영' + 전체) > 늘어난 유형 넘김 카드 > 페이지 점
/// 숫자 없이 반영 사실만 표시, 요약·근거는 '전체'(문제 탭 최신 경향)에서
class ExamTrendHomeSection extends StatefulWidget {
  const ExamTrendHomeSection({
    super.key,
    required this.patterns,
    required this.onSolveTopic,
    required this.onViewAll,
  });

  /// 늘어난 유형 (보여 줄 순서대로, 날짜별 시작 회전은 호출부)
  final List<ExamTrendPattern> patterns;
  final void Function(String topicCode, String topicName) onSolveTopic;
  final VoidCallback onViewAll;

  /// 섹션 제목 문구 원본
  static const String title = '이번 시험 출제 경향';

  /// 반영 표시 문구 원본
  static const String reflectedLabel = '최신 기출 반영';

  /// '전체' 버튼 문구 원본
  static const String viewAllLabel = '전체';

  /// '전체' 버튼 스크린리더 문구 (무엇의 전체인지 포함)
  static const String viewAllSemanticLabel = '$title 전체 보기';

  @override
  State<ExamTrendHomeSection> createState() => _ExamTrendHomeSectionState();
}

class _ExamTrendHomeSectionState extends State<ExamTrendHomeSection> {
  final _pageController = PageController(
    viewportFraction: _pageViewportFraction,
  );
  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final patterns = widget.patterns;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(colors),
        if (patterns.isNotEmpty) ...[
          const SizedBox(height: PassqlSpacing.sm),
          // 넘김 높이: 카드 높이와 같게 (글자 배율 반영)
          SizedBox(
            height: ExamTrendPatternCard.totalHeightOf(context),
            child: PageView.builder(
              controller: _pageController,
              // 첫 카드는 왼쪽 정렬, 다음 카드가 오른쪽에 걸쳐 보임
              padEnds: false,
              itemCount: patterns.length,
              onPageChanged: (pageIndex) =>
                  setState(() => _currentPageIndex = pageIndex),
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(right: PassqlSpacing.sm),
                child: ExamTrendPatternCard(
                  pattern: patterns[index],
                  onSolveTopic: widget.onSolveTopic,
                ),
              ),
            ),
          ),
          if (patterns.length > 1) ...[
            const SizedBox(height: PassqlSpacing.sm),
            PassqlPageDots(
              count: patterns.length,
              currentIndex: _currentPageIndex,
            ),
          ],
        ],
      ],
    );
  }

  /// 머리: 제목 + 아래 '최신 기출 반영' 표시, 오른쪽 '전체 >'
  Widget _buildHeader(PassqlColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 이동(로터·제목 탐색)용 머리글, 큰 글자면 줄여서 한 줄 유지
              Semantics(
                header: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    ExamTrendHomeSection.title,
                    maxLines: 1,
                    softWrap: false,
                    style: PassqlTypography.title2.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PassqlSpacing.hairlineGap),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    size: PassqlIconSize.xs,
                    color: colors.accentText,
                  ),
                  const SizedBox(width: PassqlSpacing.xxs),
                  Flexible(
                    child: Text(
                      ExamTrendHomeSection.reflectedLabel,
                      style: PassqlTypography.footnoteSemibold.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: PassqlSpacing.xxs),
        PassqlSemanticButton(
          label: ExamTrendHomeSection.viewAllSemanticLabel,
          onTap: widget.onViewAll,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            // 글자 폭이 좁아도 누르는 영역은 44x44
            minimumSize: const Size.square(PassqlSize.minTouchTarget),
            onPressed: widget.onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ExamTrendHomeSection.viewAllLabel,
                  style: PassqlTypography.subheadlineSemibold.copyWith(
                    color: colors.accentText,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: PassqlIconSize.xs,
                  color: colors.accentText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
