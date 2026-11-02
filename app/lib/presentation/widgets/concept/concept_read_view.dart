import 'package:flutter/material.dart';

import '../../../data/models/concept/concept_models.dart';
import '../../design/design.dart';
import 'concept_markdown_body.dart';

/// 개념 읽기 화면 (#764): 핵심 구간 하나 또는 자세히(문단 수·읽는 시간 줄 > 문단 구간들, 사이 회색 띠).
/// 깊이 전환은 위 세그먼트(핵심·자세히·문제)가 맡는다
/// 다시 읽기 예약 앵커가 있으면 그 문단으로 스크롤, 자세히를 끝까지 읽으면 읽음 알림 1회
class ConceptReadView extends StatefulWidget {
  const ConceptReadView({
    super.key,
    required this.detail,
    required this.depth,
    required this.pendingAnchor,
    required this.onAnchorScrolled,
    required this.onReachedDetailEnd,
  });

  final ConceptDetailResponse detail;
  final ConceptReadingDepth depth;
  final String? pendingAnchor;
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
    final sections = widget.detail.detailSections;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView(
        padding: const EdgeInsets.only(bottom: PassqlSpacing.xxl),
        children: [
          if (isDetail) ...[
            _DetailSummaryLine(sections: sections),
            for (final (index, section) in sections.indexed) ...[
              if (index > 0) const PassqlSectionGap(),
              KeyedSubtree(
                key: _keyOf(section.anchor),
                child: _DetailSection(order: index + 1, section: section),
              ),
            ],
          ] else
            _CoreSection(coreMd: widget.detail.coreMd ?? ''),
        ],
      ),
    );
  }
}

/// 핵심: "꼭 기억할 것 N가지" 구간 하나 (개수를 먼저 알려 훑어보기 쉽게)
class _CoreSection extends StatelessWidget {
  const _CoreSection({required this.coreMd});

  final String coreMd;

  // 글머리 줄 ("- " 로 시작하는 줄) 수 = 기억할 것 개수
  static final RegExp _bulletLine = RegExp(r'^\s*[-*] ', multiLine: true);

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final bulletCount = _bulletLine.allMatches(coreMd).length;
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              bulletCount > 1 ? '꼭 기억할 것 $bulletCount가지' : '꼭 기억할 것',
              style: PassqlTypography.title3.copyWith(color: colors.label),
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          ConceptMarkdownBody(coreMd),
        ],
      ),
    );
  }
}

/// 자세히 맨 위 한 줄: "문단 N개 · 약 M분" (읽는 시간은 글자 수로 앱에서 계산)
class _DetailSummaryLine extends StatelessWidget {
  const _DetailSummaryLine({required this.sections});

  final List<ConceptDetailSection> sections;

  // 한국어 설명글을 소리 내지 않고 읽는 분당 글자 수 근사 (짧은 글도 최소 1분)
  static const int _charactersPerMinute = 500;

  @override
  Widget build(BuildContext context) {
    // 표 줄(| 로 시작)은 훑어보는 자료라 읽는 시간에서 뺀다 (표까지 세면 17분처럼 과하게 나옴)
    final characterCount = sections.fold<int>(
      0,
      (sum, section) =>
          sum +
          section.title.length +
          section.bodyMd
              .split('\n')
              .where((line) => !line.trimLeft().startsWith('|'))
              .fold<int>(0, (lineSum, line) => lineSum + line.length),
    );
    final minutes = (characterCount / _charactersPerMinute).ceil().clamp(1, 99);
    return ColoredBox(
      color: context.passqlColors.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.md,
          PassqlSpacing.md,
          0,
        ),
        child: Text(
          '문단 ${sections.length}개 · 약 $minutes분',
          style: PassqlTypography.footnote.copyWith(
            color: context.passqlColors.secondaryLabel,
          ),
        ),
      ),
    );
  }
}

/// 자세히 문단 한 구간: 보라 번호 + 제목 + 본문
class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.order, required this.section});

  final int order;
  final ConceptDetailSection section;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return PassqlSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                style: PassqlTypography.headline.copyWith(color: colors.label),
                children: [
                  TextSpan(
                    text: '$order  ',
                    style: TextStyle(color: colors.accentText),
                  ),
                  TextSpan(text: section.title),
                ],
              ),
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          ConceptMarkdownBody(section.bodyMd),
        ],
      ),
    );
  }
}
