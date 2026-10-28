import 'package:flutter/cupertino.dart';

import '../../design/design.dart';

/// 긴 의견 본문: [maxLines] 를 넘을 때만 접고 아래 '더 보기'로 펼친다 (#741)
/// 펼친 뒤에는 다시 접지 않는다 (읽던 자리가 튀지 않게)
class CommunityExpandableText extends StatefulWidget {
  const CommunityExpandableText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 3,
  });

  final String text;
  final TextStyle style;
  final int maxLines;

  @override
  State<CommunityExpandableText> createState() =>
      _CommunityExpandableTextState();
}

class _CommunityExpandableTextState extends State<CommunityExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (_isExpanded) return Text(widget.text, style: widget.style);
    return LayoutBuilder(
      builder: (context, constraints) {
        // 실제 폭·글자 크기 배율로 줄 수를 재야 3줄 이하 글에 '더 보기'가 붙지 않는다
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final isOverflowing = painter.didExceedMaxLines;
        painter.dispose();
        if (!isOverflowing) return Text(widget.text, style: widget.style);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: widget.style,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
            ),
            PassqlPressable(
              onTap: () => setState(() => _isExpanded = true),
              semanticLabel: '의견 더 보기',
              hasMinimumTouchTarget: true,
              child: Text(
                '더 보기',
                style: PassqlTypography.subheadline.copyWith(
                  color: context.passqlColors.accentText,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
