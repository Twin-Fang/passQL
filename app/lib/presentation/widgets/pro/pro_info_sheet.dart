import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/profile_pass_values.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import 'pro_benefits.dart';
import 'pro_offer_sheet.dart';
import 'pro_purchase_feedback.dart';

/// 정보 시트 닫힘 사유 2종: 복원 성공 > 토스트, 연장 > 이용권 시트
enum _ProInfoSheetResult { restored, extend }

/// 이용권 정보 시트 (#749): 문장 제목(오늘 더 푼 문제) > 기간 줄 > 내 탑승권(남은 날) > 이용 중인 혜택(펼친 목록) > 구매일·주문 번호(복사) > 연장 버튼 > 작은 복원
/// 구매일·주문 번호는 서버가 주기 전까지 null 이고, 값이 있을 때만 행을 그림
/// 연장: 정보 시트 닫힘 > 이용권 시트 (시트 위에 시트를 겹치지 않음, 서버가 현재 만료일 뒤로 이어 붙임)
Future<void> showProInfoSheet(
  BuildContext context,
  WidgetRef ref, {
  DateTime? proExpiresAt,
  DateTime? purchasedAt,
  String? orderId,
}) async {
  final result = await showPassqlSheet<_ProInfoSheetResult>(
    context,
    builder: (_) => _ProInfoSheetBody(
      proExpiresAt: proExpiresAt,
      purchasedAt: purchasedAt,
      orderId: orderId,
    ),
  );
  if (!context.mounted) return;
  switch (result) {
    case _ProInfoSheetResult.restored:
      showAppToast(context, proPurchaseSucceededMessage);
    case _ProInfoSheetResult.extend:
      await showProOfferSheet(context, ref);
    case null:
      break;
  }
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

  /// 마지막 복원 결과 안내 (복원 버튼 아래 한 줄)
  String? _statusMessage;

  /// 복원: 스토어 보유 조회 > 등급 갱신(시트가 닫혀도 실행) > 성공이면 닫기, 아니면 시트 안 안내
  Future<void> _restore() async {
    setState(() {
      _isRestoring = true;
      _statusMessage = null;
    });
    final container = ProviderScope.containerOf(context);
    final outcome = await ref.read(proPurchasePortProvider).restorePurchases();
    await refreshPlanIfPurchased(container, outcome);
    if (!mounted) return;
    if (outcome == ProPurchaseOutcome.success) {
      Navigator.of(context).pop(_ProInfoSheetResult.restored);
      return;
    }
    setState(() {
      _isRestoring = false;
      _statusMessage = proPurchaseStatusMessageOf(outcome);
    });
  }

  Future<void> _copyOrderId(String orderId) async {
    await Clipboard.setData(ClipboardData(text: orderId));
    if (!mounted) return;
    showAppToast(context, '주문 번호를 복사했어요');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final expiresAt = widget.proExpiresAt;
    final purchasedAt = widget.purchasedAt;
    final orderId = widget.orderId;
    final plan = ref.watch(knownPlanProvider);
    final schedule = ref.watch(examScheduleProvider).valueOrNull;
    final nickname =
        ref.watch(settingsDataProvider).valueOrNull?.nickname ?? '';
    final extra = extraSolvedToday(
      used: plan?.todayRandomSolvedCount ?? 0,
      limit: plan?.dailyFreeLimit ?? 0,
    );
    final daysLeft = expiresAt == null ? null : daysUntilDate(expiresAt);
    final benefits = proBenefits(dailyFreeLimit: plan?.dailyFreeLimit ?? 0);
    final period = expiresAt == null
        ? null
        : purchasedAt == null
        ? '${formatDottedDate(expiresAt)}까지'
        : '${formatDottedDate(purchasedAt)} – ${formatDottedDate(expiresAt)}';
    final examDate = schedule == null
        ? null
        : DateTime.tryParse(schedule.examDate);
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
          // 「이용권」 글자 대신 받은 혜택을 숫자로 말하는 문장 제목 (스크린리더 머리글)
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                style: PassqlTypography.title2.copyWith(color: colors.label),
                children: extra != null
                    ? [
                        const TextSpan(text: '오늘 이용권 덕분에\n'),
                        TextSpan(
                          text: '$extra문제',
                          style: TextStyle(color: colors.accentText),
                        ),
                        const TextSpan(text: ' 더 풀었어요!'),
                      ]
                    // 남은 날은 탑승권 칸 한 곳에만
                    : [
                        TextSpan(
                          text: '제한 없이',
                          style: TextStyle(color: colors.accentText),
                        ),
                        const TextSpan(text: ' 풀 수 있어요'),
                      ],
              ),
            ),
          ),
          if (period != null) ...[
            const SizedBox(height: PassqlSpacing.xxs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '내 탑승권 기간',
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ),
                Text(
                  period,
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PassqlSpacing.xs),
            Divider(
              height: PassqlSize.hairline * 3,
              thickness: PassqlSize.hairline * 3,
              color: colors.label,
            ),
          ],
          const SizedBox(height: PassqlSpacing.md),
          PassqlPassTicket(
            tier: PassqlPassTicketTier.pro,
            destination: schedule == null
                ? 'SQLD'
                : '${schedule.certType} ${schedule.round}회',
            fields: [
              PassqlPassTicketField('수험생', nickname),
              if (daysLeft != null) PassqlPassTicketField('남은 날', '$daysLeft일'),
              if (examDate != null)
                PassqlPassTicketField(
                  '시험일',
                  '${examDate.month.toString().padLeft(2, '0')}.${examDate.day.toString().padLeft(2, '0')}',
                ),
            ],
            benefitIcons: [for (final benefit in benefits) benefit.icon],
            stubLabel: '사용 중',
            hasSweep: true,
            isFloating: true,
            semanticLabel: 'passQL PRO PASS, 이용권 사용 중',
          ),
          const SizedBox(height: PassqlSpacing.xl),
          // 이용 중인 혜택: 접지 않고 한 번에 (아이콘은 한 색)
          Semantics(
            header: true,
            child: Text(
              '이용 중인 혜택',
              style: PassqlTypography.headline.copyWith(color: colors.label),
            ),
          ),
          const SizedBox(height: PassqlSpacing.xs),
          for (final benefit in benefits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
              child: Row(
                children: [
                  PassqlIconTile(
                    icon: benefit.icon,
                    color: colors.accent,
                    isCompact: true,
                  ),
                  const SizedBox(width: PassqlSpacing.xs),
                  Expanded(
                    child: Text(
                      benefit.label,
                      style: PassqlTypography.subheadline.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ),
                  Text(
                    benefitInUseLabel(benefit),
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: PassqlSpacing.sm),
          if (purchasedAt != null)
            _InfoRow(
              title: '구매일',
              trailing: _valueText(context, formatDottedDate(purchasedAt)),
            ),
          if (orderId != null)
            // 문의할 때 쓰는 값이라 줄 전체를 누르면 복사 (설정 회원 ID 복사와 같은 방식)
            PassqlPressable(
              semanticLabel: '주문 번호 $orderId, 눌러서 복사',
              onTap: () => _copyOrderId(orderId),
              child: _InfoRow(
                title: '주문 번호',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: _valueText(context, orderId)),
                    const SizedBox(width: PassqlSpacing.xxs),
                    Icon(
                      CupertinoIcons.doc_on_doc,
                      size: PassqlIconSize.xs,
                      color: colors.accentText,
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: PassqlSpacing.md),
          // 연장: 이용권 시트에서 기간 고름 (복원 중에는 막음)
          PassqlButton(
            label: '이용권 연장하기',
            variant: PassqlButtonVariant.tinted,
            onPressed: _isRestoring
                ? null
                : () => Navigator.of(context).pop(_ProInfoSheetResult.extend),
          ),
          // 복원은 버튼 대신 작은 글자 한 줄 (누르는 높이 44는 유지)
          PassqlPressable(
            hasMinimumTouchTarget: true,
            onTap: _isRestoring ? null : _restore,
            semanticLabel: '이전에 구매했나요? 복원하기',
            child: Center(
              child: _isRestoring
                  ? const PassqlLoadingIndicator()
                  : Text.rich(
                      TextSpan(
                        style: PassqlTypography.caption.copyWith(
                          color: colors.secondaryLabel,
                        ),
                        children: const [
                          TextSpan(text: '이전에 구매했나요? '),
                          TextSpan(
                            text: '복원하기',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          if (_statusMessage != null)
            Text(
              _statusMessage!,
              textAlign: TextAlign.center,
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
        ],
      ),
    );
  }

  Widget _valueText(BuildContext context, String text) => Text(
    text,
    textAlign: TextAlign.end,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: PassqlTypography.subheadline.copyWith(
      color: context.passqlColors.secondaryLabel,
    ),
  );
}

/// 정보 한 줄: 왼쪽 항목, 오른쪽 값 (시트 좌우 여백 안에 놓여 자체 좌우 여백 없음)
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      constraints: const BoxConstraints(minHeight: PassqlSize.rowMin),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.separator,
            width: PassqlSize.hairline,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(width: PassqlSpacing.md),
          Expanded(
            child: Align(alignment: Alignment.centerRight, child: trailing),
          ),
        ],
      ),
    );
  }
}
