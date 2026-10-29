import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 프로 안내 시트 아래 고정 구매 버튼 + 결과 안내 한 줄 (스크롤 밖, 시트가 길어도 늘 보임)
class ProOfferBuyBar extends StatelessWidget {
  const ProOfferBuyBar({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    required this.inlineMessage,
  });

  /// 예: 3개월 이용권 ₩9,900
  final String label;
  final bool isLoading;

  /// 가격 조회 중·상품 없음·결제 중이면 null > 누를 수 없음
  final VoidCallback? onPressed;

  /// 결제·복원 결과 또는 가격 없음 안내 (없으면 줄 생략)
  final String? inlineMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final inlineMessage = this.inlineMessage;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        PassqlSpacing.xs,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlButton(
            label: label,
            isLoading: isLoading,
            onPressed: onPressed,
          ),
          if (inlineMessage != null) ...[
            const SizedBox(height: PassqlSpacing.xs),
            Text(
              inlineMessage,
              textAlign: TextAlign.center,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
