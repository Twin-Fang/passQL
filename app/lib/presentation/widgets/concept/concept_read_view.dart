import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_markdown_body.dart';

/// 개념 읽기 화면: 깊이 전환(핵심만·자세히) > 핵심만 카드 또는 자세히 문단 카드들
/// 다시 읽기 예약 앵커가 있으면 그 문단으로 스크롤, 자세히를 끝까지 읽으면 읽음 알림 1회
class ConceptReadView extends StatefulWidget {
  const ConceptReadView({
    super.key,
    required this.detail,
    required this.depth,
    required this.pendingAnchor,
    required this.onDepthSelected,
    required this.onAnchorScrolled,
    required this.onReachedDetailEnd,
  });

  final ConceptDetailResponse detail;
  final ConceptReadingDepth depth;
  final String? pendingAnchor;
  final ValueChanged<ConceptReadingDepth> onDepthSelected;
  final VoidCallback onAnchorScrolled;
  final VoidCallback onReachedDetailEnd;

  @override
  State<ConceptReadView> createState() => _ConceptReadViewState();
}

class _ConceptReadViewState extends State<ConceptReadView> {
  // 끝까지 읽음 판정 여유 (스크롤 끝에서 이 픽셀 안이면 끝)
  static const double _readEndTolerancePixels = 24;

  final Map<String, GlobalKey> _sectionKeyByAnchor = {};
  bool _hasReportedDetailEnd = false;

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

  /// 다시 읽기: 다음 프레임에 해당 문단을 화면 위쪽으로 > 예약 비움
  void _scheduleAnchorScroll() {
    final anchor = widget.pendingAnchor;
    if (anchor == null || widget.depth != ConceptReadingDepth.detail) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionContext = _sectionKeyByAnchor[anchor]?.currentContext;
      if (sectionContext != null && mounted) {
        Scrollable.ensureVisible(
          sectionContext,
          duration: PassqlMotion.durationOf(context, PassqlMotion.standard),
          curve: PassqlMotion.curve,
        );
      }
      widget.onAnchorScrolled();
    });
  }

  /// 자세히를 끝까지 내렸으면 읽음 (한 번만)
  bool _onScroll(ScrollNotification notification) {
    final isDetail = widget.depth == ConceptReadingDepth.detail;
    if (isDetail &&
        !_hasReportedDetailEnd &&
        notification.metrics.extentAfter <= _readEndTolerancePixels) {
      _hasReportedDetailEnd = true;
      widget.onReachedDetailEnd();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDetail = widget.depth == ConceptReadingDepth.detail;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          PassqlSpacing.lg,
          PassqlSpacing.sm,
          PassqlSpacing.lg,
          PassqlSpacing.xxl,
        ),
        children: [
          // 깊이 전환은 모드 전환(읽기·풀기)보다 한 단계 작게: 왼쪽 정렬, 폭 제한
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: PassqlSize.depthSwitchMaxWidth),
              child: PassqlSegmentedControl<ConceptReadingDepth>(
                segments: const [
                  PassqlSegment(value: ConceptReadingDepth.core, label: '핵심만'),
                  PassqlSegment(value: ConceptReadingDepth.detail, label: '자세히'),
                ],
                selectedValue: widget.depth,
                onSelected: widget.onDepthSelected,
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.md),
          if (isDetail)
            for (final (index, section)
                in widget.detail.detailSections.indexed) ...[
              if (index > 0) const SizedBox(height: PassqlSpacing.md),
              KeyedSubtree(
                key: _keyOf(section.anchor),
                child: _DetailSectionCard(order: index + 1, section: section),
              ),
            ]
          else
            _CoreCard(coreMd: widget.detail.coreMd ?? ''),
        ],
      ),
    );
  }
}

/// 핵심만: "꼭 기억할 것" 카드 하나
class _CoreCard extends StatelessWidget {
  const _CoreCard({required this.coreMd});

  final String coreMd;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      padding: const EdgeInsets.all(PassqlSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '꼭 기억할 것',
            style: PassqlTypography.headline.copyWith(color: colors.label),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          ConceptMarkdownBody(coreMd),
        ],
      ),
    );
  }
}

/// 자세히 문단 한 장: 번호 붙은 제목 + 본문
class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({required this.order, required this.section});

  final int order;
  final ConceptDetailSection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlCard(
      padding: const EdgeInsets.all(PassqlSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              '$order. ${section.title}',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          ConceptMarkdownBody(section.bodyMd),
        ],
      ),
    );
  }
}
