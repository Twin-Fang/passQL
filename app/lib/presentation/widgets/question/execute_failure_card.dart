import 'package:flutter/material.dart';

import '../../design/design.dart';

/// SQL 실행 요청 실패 카드: 실패 표시 + 사유 문구(AppException.message) + 다시 시도
/// SQL 오류 결과(ExecuteResultCard)와 달리 서버 응답 자체를 받지 못한 경우
class ExecuteFailureCard extends StatelessWidget {
  const ExecuteFailureCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 선택지 카드·실행 결과 카드와 같은 바깥 여백
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PassqlSpacing.md,
        vertical: PassqlSpacing.xxs,
      ),
      child: PassqlCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PassqlResultMark(isCorrect: false, label: '실행하지 못했어요'),
            const SizedBox(height: PassqlSpacing.xxs),
            Text(
              message,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
            const SizedBox(height: PassqlSpacing.xs),
            PassqlButton(
              label: '다시 시도',
              onPressed: onRetry,
              variant: PassqlButtonVariant.plain,
              size: PassqlButtonSize.small,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
