import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../data/models/member/purchase_history_entry_response.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/profile_pass_providers.dart';
import '../../providers/purchase_history_providers.dart';
import '../account/purchase_history_labels.dart';
import '../pro/pro_benefits.dart';
import '../pro/pro_info_sheet.dart';

/// 프로 이용권 카드 (#816 A안): 보라 탑승권에 남은 날 큰 숫자 + 수험생·만료일·이용권 이름, 누르면 이용권 정보 시트
/// 구매 직후 연출 대기 표시는 이 카드가 보이면 지움 (연출 없이 바로 보라 탑승권)
class ProfileProPassCard extends ConsumerStatefulWidget {
  const ProfileProPassCard({super.key, required this.nickname});

  /// 수험생 칸 (닉네임을 아직 모르면 빈칸)
  final String nickname;

  @override
  ConsumerState<ProfileProPassCard> createState() => _ProfileProPassCardState();
}

class _ProfileProPassCardState extends ConsumerState<ProfileProPassCard> {
  @override
  void initState() {
    super.initState();
    // 구매 직후 연출 대기 표시 정리 (첫 프레임 뒤, 빌드 중 상태 변경 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isRevealPending =
          ref.read(profilePassRevealPendingProvider).valueOrNull ?? false;
      if (isRevealPending) {
        ref.read(profilePassRevealPendingProvider.notifier).consume();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final plan = ref.watch(knownPlanProvider);
    final schedule = ref.watch(examScheduleProvider).valueOrNull;
    final latestEntry = _latestActiveEntryOf(
      ref.watch(purchaseHistoryProvider).valueOrNull,
    );
    final expiresAt = plan?.proExpiresAt;
    final daysLeft = expiresAt == null ? null : daysUntilDate(expiresAt);
    final passName = latestEntry == null
        ? null
        : passNameOf(
            latestEntry,
            durationDaysByProductId: durationDaysByProductIdOf(plan),
          );
    return PassqlPassTicket(
      tier: PassqlPassTicketTier.pro,
      destination: schedule == null
          ? 'SQLD'
          : '${schedule.certType} ${schedule.round}회',
      fields: [
        PassqlPassTicketField('수험생', widget.nickname),
        if (expiresAt != null)
          PassqlPassTicketField('만료일', formatDottedDate(expiresAt)),
        if (passName != null) PassqlPassTicketField('이용권', passName),
      ],
      benefitIcons: [
        for (final benefit in proBenefits(
          dailyFreeLimit: plan?.dailyFreeLimit ?? 0,
        ))
          benefit.icon,
      ],
      stubLabel: '사용 중',
      hasSweep: true,
      footer: daysLeft == null
          ? null
          : Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$daysLeft',
                    style: PassqlTypography.largeTitle.copyWith(
                      color: colors.onAccent,
                    ),
                  ),
                  TextSpan(
                    text: ' 일 남았어요',
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.onAccent,
                    ),
                  ),
                ],
              ),
            ),
      onTap: () => showProInfoSheet(
        context,
        ref,
        proExpiresAt: expiresAt,
        purchasedAt: plan?.lastPurchasedAt,
        orderId: plan?.lastOrderId,
      ),
      semanticLabel: [
        'passQL PRO PASS',
        if (daysLeft != null) '$daysLeft일 남음',
        if (expiresAt != null) '${formatDottedDate(expiresAt)}까지',
        ?passName,
        '눌러서 이용권 정보 보기',
      ].join('. '),
    );
  }

  /// 가장 최근 유효 내역 (환불·회수 제외, 서버 최신순)
  static PurchaseHistoryEntryResponse? _latestActiveEntryOf(
    List<PurchaseHistoryEntryResponse>? entries,
  ) => entries?.where((entry) => !entry.isRevoked).firstOrNull;
}
