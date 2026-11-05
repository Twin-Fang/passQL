import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_core_header.dart';
import 'concept_reading_parser.dart';
import 'concept_section_card.dart';

/// 개념 읽기 화면 (#835): 한 스크롤 = 한 줄 핵심·기억할 것 > 자세히 문단 카드들 (사이 회색 띠)
/// 앞 문단 [_alwaysOpenSectionCount]개·자주 헷갈리는 점·시험 포인트는 항상 펼침, 그 뒤 긴 일반 문단은 접힘
/// 다시 읽기 예약 앵커가 있으면 그 문단을 펼쳐 스크롤, 끝까지 읽으면 읽음 알림 1회
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
  // 처음부터 펼쳐 두는 앞 문단 수 (보통 왜 필요한가·정의·첫 예시)
  static const int _alwaysOpenSectionCount = 3;
  // 이보다 짧은 일반 문단은 접지 않음 (글자 수, 표·코드 포함 / 63개 중 17개 개념의 18문단만 접힘)
  static const int _collapsibleBodyMinCharacters = 1200;
  // 긴 글 한 줄 길이 상한 (태블릿·가로 화면에서 한 줄이 너무 길어지지 않게)
  static const double _readingContentMaxWidth = 640;

  final Map<String, GlobalKey> _sectionKeyByAnchor = {};
  // 사용자가 펼쳤거나 다시 읽기로 펼친 문단 앵커
  final Set<String> _expandedAnchors = {};
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

  /// 다시 읽기: 해당 문단 펼침 > 다음 프레임에 화면 위쪽으로 > 예약 비움
  void _scheduleAnchorScroll() {
    final anchor = widget.pendingAnchor;
    if (anchor == null) return;
    _expandedAnchors.add(anchor);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sectionContext = _sectionKeyByAnchor[anchor]?.currentContext;
      if (sectionContext != null) {
        Scrollable.ensureVisible(
          sectionContext,
          duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
          curve: PassqlMotion.curve,
        );
      }
      widget.onAnchorScrolled();
    });
  }

  /// 끝까지 내렸으면 읽음 (한 번만)
  bool _onScroll(ScrollNotification notification) {
    if (!_hasReportedEnd &&
        notification.metrics.extentAfter <= _readEndTolerancePixels) {
      _hasReportedEnd = true;
      widget.onReachedEnd();
    }
    return false;
  }

  /// 접을 문단: 앞 문단 이후의 긴 일반 문단 중 아직 펼치지 않은 것 (함정·시험 포인트는 항상 펼침)
  bool _isCollapsed(int index, ConceptDetailSection section) =>
      index >= _alwaysOpenSectionCount &&
      ConceptReadingParser.kindOf(section.anchor) ==
          ConceptSectionKind.general &&
      section.bodyMd.length >= _collapsibleBodyMinCharacters &&
      !_expandedAnchors.contains(section.anchor);

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final sections = detail.detailSections;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 넓은 화면은 가운데 읽기 폭만 쓰고 양옆은 배경 (390pt 폰은 0)
          final sideInset =
              ((constraints.maxWidth - _readingContentMaxWidth) / 2).clamp(
                0.0,
                double.infinity,
              );
          // 다시 읽기 대상이 화면 밖이어도 위치를 잡도록 문단을 모두 그림 (문단 10개 안팎)
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
                  coreMd: detail.coreMd ?? '',
                  sectionCount: sections.length,
                  readMinutes: ConceptReadingParser.estimateReadMinutes(
                    sections,
                  ),
                ),
                for (final (index, section) in sections.indexed) ...[
                  const PassqlSectionGap(),
                  KeyedSubtree(
                    key: _keyOf(section.anchor),
                    child: ConceptSectionCard(
                      order: index + 1,
                      section: section,
                      isCollapsed: _isCollapsed(index, section),
                      onExpandPressed: () =>
                          setState(() => _expandedAnchors.add(section.anchor)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
