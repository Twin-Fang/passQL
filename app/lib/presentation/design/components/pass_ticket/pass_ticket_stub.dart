part of '../passql_pass_ticket.dart';

/// 떼는 칸: 세로로 세운 바코드 무늬(줄이 위에서 아래로 쌓임) + 글자 (#966)
class _TicketStub extends StatelessWidget {
  const _TicketStub({
    required this.label,
    required this.textColor,
    required this.barcodeColor,
  });

  final String label;
  final Color textColor;
  final Color barcodeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _stubWidth,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: RotatedBox(
                quarterTurns: 1,
                child: CustomPaint(
                  painter: _BarcodePainter(
                    color: barcodeColor.withValues(alpha: _barcodeAlpha),
                  ),
                  child: const SizedBox(
                    width: _barcodeLength,
                    height: _barcodeHeight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: PassqlTypography.captionSemibold.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
