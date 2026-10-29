part of '../passql_pass_ticket.dart';

/// 떼는 칸: 바코드 무늬 + 글자. 바코드 폭은 글자 폭에 맞춘다 (양끝이 딱 맞게)
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
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: CustomPaint(
                  painter: _BarcodePainter(
                    color: barcodeColor.withValues(alpha: _barcodeAlpha),
                  ),
                  child: const SizedBox(height: _barcodeHeight),
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
      ),
    );
  }
}
