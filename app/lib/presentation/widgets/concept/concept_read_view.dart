import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_core_header.dart';
import 'concept_lesson_recap.dart';
import 'concept_reading_parser.dart';
import 'concept_section_card.dart';

/// 개념 읽기 화면 (#848): 위 읽은 정도 막대 > 한 스크롤 = 한 줄 핵심·목차 > 문단들 (사이 회색 띠) > 한 장 요약
/// 다시 읽기 예약 앵커·목차를 누르면 그 문단으로 스크롤, 끝까지 읽으면 읽음 알림 1회
class ConceptReadView extends StatefulWidget {
  const ConceptReadView({
    super.key,
    required this.detail,
    required this.pendingAnchor,
    required this.onAnchorScrolled,
    required this.onReachedEnd,
  });

  final ConceptDetailResponse detail;
  final String? pendingAnchor;
  final VoidCallback onAnchorScrolled;
  final VoidCallback onReachedEnd;

  @override
  State<ConceptReadView> createState() => _ConceptReadViewState();
}

class _ConceptReadViewState extends State<ConceptReadView> {
  // 끝까지 읽음 판정 여유 (스크롤 끝에서 이 픽셀 안이면 끝)
  static const double _readEndTolerancePixels = 24;
  // 긴 글 한 줄 길이 상한 (태블릿·가로 화면에서 한 줄이 너무 길어지지 않게)
  static const double _readingContentMaxWidth = 640;

  final Map<String, GlobalKey> _sectionKeyByAnchor = {};
  // 읽은 정도 (0~1, 위 막대)
  final ValueNotifier<double> _readFraction = ValueNotifier(0);
  bool _hasReportedEnd = false;

  GlobalKey _keyOf(String anchor) =>
      _sectionKeyByAnchor.putIfAbsent(anchor, GlobalKey.new);

  @override
  void initState() {
    super.initState();
    _scheduleAnchorScroll();
  }

  @override
  void didUpdateWidget(ConceptReadView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pendingAnchor != null &&
        widget.pendingAnchor != oldWidget.pendingAnchor) {
      _scheduleAnchorScroll();
    }
  }

  @override
  void dispose() {
    _readFraction.dispose();
    super.dispose();
  }

  /// 다시 읽기: 다음 프레임에 해당 문단을 화면 위쪽으로 > 예약 비움
  void _scheduleAnchorScroll() {
    final anchor = widget.pendingAnchor;
    if (anchor == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToSection(anchor);
      widget.onAnchorScrolled();
    });
  }

  /// 앵커 문단을 화면 위쪽으로 (목차·다시 읽기 공통)
  void _scrollToSection(String anchor) {
    final sectionContext = _sectionKeyByAnchor[anchor]?.currentContext;
    if (sectionContext == null) return;
    Scrollable.ensureVisible(
      sectionContext,
      duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
      curve: PassqlMotion.curve,
    );
  }

  /// 스크롤마다: 읽은 정도 갱신, 끝까지 내렸으면 읽음 (한 번만)
  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) return false;
    _readFraction.value = metrics.maxScrollExtent <= 0
        ? 1
        : (metrics.pixels / metrics.maxScrollExtent).clamp(0.0, 1.0);
    if (!_hasReportedEnd && metrics.extentAfter <= _readEndTolerancePixels) {
      _hasReportedEnd = true;
      widget.onReachedEnd();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final sections = detail.detailSections;
    final coreMd = detail.coreMd ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 읽은 정도 막대 (스크린리더는 읽지 않음, 진행은 스크롤 위치로 이미 전달)
        ValueListenableBuilder<double>(
          valueListenable: _readFraction,
          builder: (_, fraction, _) => PassqlProgressBar(value: fraction),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 넓은 화면은 가운데 읽기 폭만 쓰고 양옆은 배경 (390pt 폰은 0)
                final sideInset =
                    ((constraints.maxWidth - _readingContentMaxWidth) / 2)
                        .clamp(0.0, double.infinity);
                // 다시 읽기·목차 대상이 화면 밖이어도 위치를 잡도록 문단을 모두 그림 (문단 10개 안팎)
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    sideInset,
                    0,
                    sideInset,
                    PassqlSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ConceptCoreHeader(
                        summary: detail.summary,
                        sections: sections,
                        readMinutes: ConceptReadingParser.estimateReadMinutes(
                          sections,
                        ),
                        onSectionPressed: _scrollToSection,
                      ),
                      for (final (index, section) in sections.indexed) ...[
                        const PassqlSectionGap(),
                        KeyedSubtree(
                          key: _keyOf(section.anchor),
                          child: ConceptSectionCard(
                            order: index + 1,
                            section: section,
                          ),
                        ),
                      ],
                      if (coreMd.trim().isNotEmpty) ...[
                        const PassqlSectionGap(),
                        ConceptLessonRecap(coreMd: coreMd),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
