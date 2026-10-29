import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 각주: 기간이 끝나면 무료로 돌아감
const String _footnote = '자동 결제 없음 · 기간이 끝나면 무료로 돌아가요';

/// iOS 결제 수단 안내 (App Store 결제 시트 안내, 다른 결제 경로 언급 금지)
const String _appleIdPaymentNotice = '구매는 Apple ID 계정으로 결제됩니다.';

/// 프로 안내 시트 아래 안내: iOS 결제 수단 > 복원 한 줄 > 각주
class ProOfferPaymentNotes extends StatelessWidget {
  const ProOfferPaymentNotes({
    super.key,
    required this.isIos,
    required this.onRestoreTap,
  });

  /// iOS 면 Apple ID 결제 안내 줄
  final bool isIos;

  /// 복원 탭 (결제 중이면 null)
  final VoidCallback? onRestoreTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isIos) ...[
          const SizedBox(height: PassqlSpacing.xs),
          Text(
            _appleIdPaymentNotice,
            textAlign: TextAlign.center,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
        ],
        // 복원은 버튼 대신 작은 글자 한 줄 (누르는 높이 44는 유지)
        PassqlPressable(
          hasMinimumTouchTarget: true,
          onTap: onRestoreTap,
          semanticLabel: '이전에 구매했나요? 복원하기',
          child: Center(
            child: Text.rich(
              TextSpan(
                style: PassqlTypography.caption.copyWith(
                  color: colors.secondaryLabel,
                ),
                children: const [
                  TextSpan(text: '이전에 구매했나요? '),
                  TextSpan(
                    text: '복원하기',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
            ),
          ),
        ),
        Text(
          _footnote,
          textAlign: TextAlign.center,
          style: PassqlTypography.caption.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}
