import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import 'pro_purchase_feedback.dart';

/// 이용권 정보 시트: 상태 > 만료일 > 구매일 > 주문 번호 > 구매 복원
/// 구매일·주문 번호는 서버가 주기 전까지 null 이고, 값이 있을 때만 행을 그림
Future<void> showProInfoSheet(
  BuildContext context, {
  DateTime? proExpiresAt,
  DateTime? purchasedAt,
  String? orderId,
}) {
  return showPassqlSheet<void>(
    context,
    title: '회차 패스',
    builder: (_) => _ProInfoSheetBody(
      proExpiresAt: proExpiresAt,
      purchasedAt: purchasedAt,
      orderId: orderId,
    ),
  );
}

class _ProInfoSheetBody extends ConsumerStatefulWidget {
  const _ProInfoSheetBody({
    required this.proExpiresAt,
    required this.purchasedAt,
    required this.orderId,
  });

  final DateTime? proExpiresAt;
  final DateTime? purchasedAt;
  final String? orderId;

  @override
  ConsumerState<_ProInfoSheetBody> createState() => _ProInfoSheetBodyState();
}

class _ProInfoSheetBodyState extends ConsumerState<_ProInfoSheetBody> {
  /// 복원 조회 중 (버튼 중복 탭 방지)
  bool _isRestoring = false;

  /// 복원: 스토어 보유 조회 > 안내 (성공이면 등급 다시 받고 닫기)
  Future<void> _restore() async {
    setState(() => _isRestoring = true);
    final outcome = await ref.read(proPurchasePortProvider).restorePurchases();
    if (!mounted) return;
    final isOpened = await applyProPurchaseOutcome(context, ref, outcome);
    if (!mounted) return;
    setState(() => _isRestoring = false);
    if (isOpened) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final expiresAt = widget.proExpiresAt;
    final purchasedAt = widget.purchasedAt;
    final orderId = widget.orderId;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.md,
        0,
        PassqlSpacing.md,
        PassqlSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlGroupedSection(
            children: [
              _InfoRow(
                title: '상태',
                value: Text(
                  '회차 패스 이용 중',
                  style: PassqlTypography.body.copyWith(
                    color: context.passqlColors.accent,
                  ),
                ),
              ),
              if (expiresAt != null)
                _InfoRow(
                  title: '만료일',
                  value: _valueText(context, formatDottedDate(expiresAt)),
                ),
              if (purchasedAt != null)
                _InfoRow(
                  title: '구매일',
                  value: _valueText(context, formatDottedDate(purchasedAt)),
                ),
              if (orderId != null)
                _InfoRow(title: '주문 번호', value: _valueText(context, orderId)),
            ],
          ),
          const SizedBox(height: PassqlSpacing.md),
          PassqlButton(
            label: '구매 복원',
            variant: PassqlButtonVariant.tinted,
            isLoading: _isRestoring,
            onPressed: _restore,
          ),
        ],
      ),
    );
  }

  Widget _valueText(BuildContext context, String text) => Text(
    text,
    textAlign: TextAlign.end,
    style: PassqlTypography.body.copyWith(
      color: context.passqlColors.secondaryLabel,
    ),
  );
}

/// 정보 한 줄: 왼쪽 항목, 오른쪽 값
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PassqlSpacing.md),
        child: Row(
          children: [
            Text(
              title,
              style: PassqlTypography.body.copyWith(
                color: context.passqlColors.label,
              ),
            ),
            const SizedBox(width: PassqlSpacing.md),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: value),
            ),
          ],
        ),
      ),
    );
  }
}
