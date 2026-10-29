import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_format.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/pro_ui_providers.dart';
import '../../providers/profile_pass_providers.dart';
import '../pro/pro_benefits.dart';
import '../pro/pro_info_sheet.dart';
import '../pro/pro_offer_sheet.dart';

/// 내 프로필 탑승권 자리 (#749): 무료 = 항상 펼친 회색 탑승권, 프로 = 기본 접힌 한 줄(펼치면 보라 탑승권),
/// 결제 꺼짐·등급 모름 = 자리째 없음 (지금 등급 카드와 같은 판정)
class ProfilePassSlot extends ConsumerWidget {
  const ProfilePassSlot({super.key, required this.nickname});

  /// 승객 칸 (닉네임을 아직 모르면 빈칸)
  final String nickname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(knownPlanProvider);
    final schedule = ref.watch(examScheduleProvider).valueOrNull;
    if (ref.watch(shouldShowProUiProvider)) {
      return _FreePass(plan: plan, schedule: schedule, nickname: nickname);
    }
    if (ref.watch(shouldShowProBadgeProvider)) {
      return _ProPass(plan: plan, schedule: schedule, nickname: nickname);
    }
    return const SizedBox.shrink();
  }
}

/// 시험 목적지·날짜 (일정이 없으면 SQLD + 준비 중)
({String destination, String? examDate, int? days}) _examOf(
  ExamScheduleResponse? schedule,
) {
  if (schedule == null) {
    return (destination: 'SQLD', examDate: null, days: null);
  }
  final date = DateTime.tryParse(schedule.examDate);
  return (
    destination: '${schedule.certType} ${schedule.round}회',
    examDate: date == null ? null : _monthDay(date),
    days: daysUntilExam(schedule.examDate),
  );
}

String _monthDay(DateTime date) =>
    '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

List<({IconData icon, Color color})> _benefitIconsOf(
  BuildContext context,
  int dailyFreeLimit,
) {
  return [
    for (final benefit in proBenefits(dailyFreeLimit: dailyFreeLimit))
      (icon: benefit.icon, color: benefitColorOf(context, benefit)),
  ];
}

/// 무료: 시험일·남은 날·승객 + 잠긴 혜택 아이콘 + 오늘 사용량 게이지. 어디를 눌러도 이용권 시트
class _FreePass extends ConsumerWidget {
  const _FreePass({
    required this.plan,
    required this.schedule,
    required this.nickname,
  });

  final MemberPlanResponse? plan;
  final ExamScheduleResponse? schedule;
  final String nickname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.passqlColors;
    final exam = _examOf(schedule);
    final limit = plan?.dailyFreeLimit ?? 0;
    final used = plan?.todayRandomSolvedCount ?? 0;
    final isDone = isFreeLimitReached(used: used, limit: limit);
    final examDate = exam.examDate;
    return PassqlPassTicket(
      tier: PassqlPassTicketTier.free,
      destination: exam.destination,
      fields: [
        if (examDate != null) ...[
          PassqlPassTicketField('시험일', examDate),
          PassqlPassTicketField('남은 날', examDdayLabel(exam.days)),
        ] else
          const PassqlPassTicketField('시험 일정', '준비 중'),
        PassqlPassTicketField('승객', nickname),
      ],
      benefitIcons: _benefitIconsOf(context, limit),
      stubLabel: 'PRO로\n업그레이드',
      // 등급 응답이 없으면(디버그 강제 등) 사용량 줄 생략
      footer: plan == null || limit <= 0
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isDone ? '오늘 무료 풀기를 다 썼어요' : '오늘 랜덤 풀기',
                        style: PassqlTypography.caption.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ),
                    Text(
                      '$used/$limit문제 사용',
                      style: PassqlTypography.captionSemibold.copyWith(
                        color: colors.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xxs),
                PassqlPassUsageGauge(value: used / limit),
              ],
            ),
      onTap: () => showProOfferSheet(context, ref),
      onBenefitTap: (index) =>
          showProOfferSheet(context, ref, focusedBenefitIndex: index),
      semanticLabel:
          'passQL PASS 무료. ${exam.destination}. 오늘 $used/$limit문제 사용. 눌러서 이용권 보기',
    );
  }
}

/// 프로: 기본 접힌 한 줄, 펼치면 보라 탑승권. 구매 직후 첫 진입은 회색 > 보라 연출 한 번
class _ProPass extends ConsumerStatefulWidget {
  const _ProPass({
    required this.plan,
    required this.schedule,
    required this.nickname,
  });

  final MemberPlanResponse? plan;
  final ExamScheduleResponse? schedule;
  final String nickname;

  @override
  ConsumerState<_ProPass> createState() => _ProPassState();
}

class _ProPassState extends ConsumerState<_ProPass> {
  // 구매 연출을 이번 화면에서 보여 줬으면 연출이 끝난 뒤에도 펼쳐 둔다 (저장된 접힘 값은 다음 진입부터)
  bool _isKeptOpenAfterReveal = false;

  MemberPlanResponse? get plan => widget.plan;
  ExamScheduleResponse? get schedule => widget.schedule;

  @override
  Widget build(BuildContext context) {
    final isCollapsed =
        !_isKeptOpenAfterReveal &&
        (ref.watch(profilePassCollapsedProvider).valueOrNull ?? true);
    final isRevealPending =
        ref.watch(profilePassRevealPendingProvider).valueOrNull ?? false;
    if (isRevealPending) _isKeptOpenAfterReveal = true;
    final expiresAt = plan?.proExpiresAt;
    final daysLeft = expiresAt == null ? null : daysUntilDate(expiresAt);
    void openInfo() => showProInfoSheet(
      context,
      proExpiresAt: expiresAt,
      purchasedAt: plan?.lastPurchasedAt,
      orderId: plan?.lastOrderId,
    );

    if (isRevealPending) {
      return _PassReveal(
        ticket: _proTicket(
          context,
          expiresAt,
          daysLeft,
          onTap: openInfo,
          hasHolo: true,
        ),
        placeholder: _proTicket(
          context,
          expiresAt,
          daysLeft,
          tier: PassqlPassTicketTier.free,
        ),
        onDone: () =>
            ref.read(profilePassRevealPendingProvider.notifier).consume(),
      );
    }
    if (isCollapsed) {
      return _CollapsedProLine(
        expiresAt: expiresAt,
        daysLeft: daysLeft,
        onTap: () =>
            ref.read(profilePassCollapsedProvider.notifier).setCollapsed(false),
      );
    }
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _proTicket(context, expiresAt, daysLeft, onTap: openInfo),
        PassqlPressable(
          onTap: () {
            setState(() => _isKeptOpenAfterReveal = false);
            ref.read(profilePassCollapsedProvider.notifier).setCollapsed(true);
          },
          hasMinimumTouchTarget: true,
          semanticLabel: '탑승권 접기',
          child: Center(
            child: Text(
              '접기 ⌃',
              style: PassqlTypography.footnote.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _proTicket(
    BuildContext context,
    DateTime? expiresAt,
    int? daysLeft, {
    PassqlPassTicketTier tier = PassqlPassTicketTier.pro,
    VoidCallback? onTap,
    bool hasHolo = false,
  }) {
    final exam = _examOf(schedule);
    final examDate = exam.examDate;
    return PassqlPassTicket(
      tier: tier,
      destination: exam.destination,
      // 이용권 정보 시트와 같은 칸 순서 (만료일은 시트·접힌 줄·스크린리더가 알려 준다)
      fields: [
        PassqlPassTicketField('승객', widget.nickname),
        if (daysLeft != null) PassqlPassTicketField('남은 날', '$daysLeft일'),
        if (examDate != null) PassqlPassTicketField('시험일', examDate),
      ],
      benefitIcons: _benefitIconsOf(context, plan?.dailyFreeLimit ?? 0),
      stubLabel: '사용 중',
      hasSweep: tier == PassqlPassTicketTier.pro,
      hasHolo: hasHolo,
      onTap: onTap,
      semanticLabel: expiresAt == null
          ? 'passQL PRO PASS. 눌러서 이용권 정보 보기'
          : 'passQL PRO PASS. ${formatDottedDate(expiresAt)}까지. 눌러서 이용권 정보 보기',
    );
  }
}

/// 프로 접힌 한 줄: PRO 칩 + 만료일 + 남은 날 + 펼침 표시 (다른 단서가 없어 여기만 칩을 쓴다)
class _CollapsedProLine extends StatelessWidget {
  const _CollapsedProLine({
    required this.expiresAt,
    required this.daysLeft,
    required this.onTap,
  });

  final DateTime? expiresAt;
  final int? daysLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final until = expiresAt;
    final summary = until == null
        ? '이용권 사용 중'
        : '이용권 ${_monthDay(until)}까지${daysLeft == null ? '' : ' · $daysLeft일 남음'}';
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: 'PRO $summary, 펼치기',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PassqlSpacing.sm,
          vertical: PassqlSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PassqlRadius.md),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.accent, colors.passGradientEnd],
          ),
        ),
        child: Row(
          children: [
            // 보라 바탕 위라 기본 PRO 칩(보라)이 묻혀 흰 바탕 칩으로 둔다
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.xs,
                vertical: PassqlSpacing.hairlineGap,
              ),
              decoration: BoxDecoration(
                color: colors.onAccent,
                borderRadius: BorderRadius.circular(PassqlRadius.sm / 2),
              ),
              child: Text(
                'PRO',
                style: PassqlTypography.captionSemibold.copyWith(
                  color: colors.accentText,
                ),
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Expanded(
              child: Text(
                summary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PassqlTypography.footnoteSemibold.copyWith(
                  color: colors.onAccent,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_down,
              size: PassqlIconSize.xs,
              color: colors.onAccent,
            ),
          ],
        ),
      ),
    );
  }
}

/// 구매 직후 첫 진입: 회색 탑승권 위로 보라 탑승권이 왼쪽부터 차오르고 홀로그램이 한 번 지나간다
/// 동작 줄이기면 바로 보라 탑승권. 끝나면 대기 표시를 지운다
class _PassReveal extends StatefulWidget {
  const _PassReveal({
    required this.ticket,
    required this.placeholder,
    required this.onDone,
  });

  final Widget ticket;
  final Widget placeholder;
  final VoidCallback onDone;

  @override
  State<_PassReveal> createState() => _PassRevealState();
}

class _PassRevealState extends State<_PassReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PassqlMotion.passReveal,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller.isAnimating || _controller.isCompleted) return;
    if (PassqlMotion.isReduced(context)) {
      _controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
      return;
    }
    // 탭 전환이 끝난 뒤 시작해야 연출이 전환에 묻히지 않는다
    Future.delayed(PassqlMotion.afterRouteTransitionDelay, () {
      if (!mounted) return;
      _controller.forward().whenComplete(widget.onDone);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.placeholder,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => ClipRect(
              clipper: _LeftFractionClipper(
                PassqlMotion.curve.transform(_controller.value),
              ),
              child: child,
            ),
            child: widget.ticket,
          ),
        ),
      ],
    );
  }
}

/// 왼쪽부터 [fraction] 만큼만 보이게 자른다 (구매 직후 색 차오름)
class _LeftFractionClipper extends CustomClipper<Rect> {
  const _LeftFractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftFractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
