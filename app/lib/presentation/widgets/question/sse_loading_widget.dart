import 'package:flutter/cupertino.dart';
import '../../design/design.dart';

/// SSE 선택지 생성 중 로딩 상태. 스피너 + 상태 메시지.
class SseLoadingWidget extends StatelessWidget {
  final String statusMessage;

  const SseLoadingWidget({super.key, this.statusMessage = '선택지 생성 중...'});

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xs,
      ),
      child: PassqlCard(
        child: Row(
          children: [
            const PassqlLoadingIndicator(),
            const SizedBox(width: PassqlSpacing.sm),
            Expanded(
              child: Text(
                statusMessage,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
