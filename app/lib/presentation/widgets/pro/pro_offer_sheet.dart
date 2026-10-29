import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pass_discount.dart';
import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/number_format.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
import '../../providers/home_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/settings_providers.dart';
import '../home/exam_dday.dart';
import '../profile/profile_pass_values.dart';
import '../../providers/profile_pass_providers.dart';
import '../common/app_toast.dart';
import 'pro_pass_option_tile.dart';
import 'pro_benefits.dart';
import 'pro_purchase_feedback.dart';

/// 시트가 떠 있는가: 한 번에 한 장만 (빠른 두 번 탭 방지)
/// 시트 본문이 사라질 때(닫힘 연출 끝·화면 해체) 내려감
bool _isOfferSheetOpen = false;

/// 구매 버튼 기본 문구(이용권 목록이 없을 때), 각주
const String _sheetTitle = '이용권';
const String _footnote = '자동 결제 없음 · 기간이 끝나면 무료로 돌아가요';

/// iOS 결제 수단 안내 (App Store 결제 시트 안내, 다른 결제 경로 언급 금지)
const String _appleIdPaymentNotice = '구매는 Apple ID 계정으로 결제됩니다.';

/// 프로 안내 시트 (모든 진입점이 공유하는 한 장, #749): 문장 제목 > 기간 줄 > 들어온 이유 > 강조 혜택 > 내 이름 PRO 탑승권 > 달라지는 점 > 이용권 고르기(1개월이면 3개월 권유) > 복원 > 각주 + 아래 고정 구매 버튼
/// 이용권 목록은 등급 응답 passOptions (서버 순서 3개월 먼저 > 첫 칸 기본 선택)
/// [reason]: 진입점별 한 줄 (예: 오늘 무료 10문제를 다 풀었어요)
/// 성공 > 시트 닫힘 > 호출 화면에서 토스트, 그 외 결과는 시트 안 한 줄
Future<void> showProOfferSheet(
  BuildContext context,
  WidgetRef ref, {
  String? reason,
  // 탑승권 혜택 아이콘에서 열었을 때 그 혜택 순서(proBenefits 기준) > 시트가 그 줄을 강조 (#749)
  int? focusedBenefitIndex,
}) async {
  if (_isOfferSheetOpen) return;
  _isOfferSheetOpen = true;
  final knownPlan = ref.read(knownPlanProvider);
  final proExpiresAt = knownPlan?.proExpiresAt;
  // 시트가 닫힐 때 호출 화면이 이미 사라졌을 수 있어 ref 는 기다리기 전에 읽어 둔다
  final revealNotifier = ref.read(profilePassRevealPendingProvider.notifier);
  try {
    final isPurchased = await showPassqlSheet<bool>(
      context,
      builder: (_) => _ProOfferSheetBody(
        passOptions: knownPlan?.passOptions ?? const [],
        // 지금 프로 이용 중일 때만 현재 만료일 > 연장 미리보기
        activeProExpiresAt:
            proExpiresAt != null && proExpiresAt.isAfter(DateTime.now())
            ? proExpiresAt
            : null,
        dailyFreeLimit: knownPlan?.dailyFreeLimit ?? 0,
        reason: reason,
        focusedBenefitIndex: focusedBenefitIndex,
        nickname: ref.read(settingsDataProvider).valueOrNull?.nickname ?? '',
        examSchedule: ref.read(examScheduleProvider).valueOrNull,
      ),
    );
    if (isPurchased == true) {
      // 어느 진입점에서 샀든 다음 프로필 진입 때 탑승권 연출을 한 번 보여 준다 (#749)
      await revealNotifier.markPending();
      if (context.mounted) showAppToast(context, proPurchaseSucceededMessage);
    }
  } catch (_) {
    // 시트를 띄우지 못한 경우만 여기서 내림
    _isOfferSheetOpen = false;
    rethrow;
  }
}

class _ProOfferSheetBody extends ConsumerStatefulWidget {
  const _ProOfferSheetBody({
    required this.passOptions,
    required this.activeProExpiresAt,
    required this.dailyFreeLimit,
    required this.reason,
    required this.focusedBenefitIndex,
    required this.nickname,
    required this.examSchedule,
  });

  final List<PassOption> passOptions;

  /// 이용 중인 프로 만료일 (무료·만료면 null)
  final DateTime? activeProExpiresAt;
  final int dailyFreeLimit;
  final String? reason;

  /// 탑승권 혜택 아이콘에서 열었으면 그 혜택 순서 (proBenefits 기준)
  final int? focusedBenefitIndex;

  /// 미리보기 탑승권 승객 칸
  final String nickname;

  /// 미리보기 탑승권 목적지·시험일, 제목의 남은 날 (없으면 일정 없는 문장)
  final ExamScheduleResponse? examSchedule;

  @override
  ConsumerState<_ProOfferSheetBody> createState() => _ProOfferSheetBodyState();
}

class _ProOfferSheetBodyState extends ConsumerState<_ProOfferSheetBody> {
  /// 상품 ID별 스토어 가격 (못 읽은 상품은 없음)
  Map<String, PassPrice> _priceByProductId = const {};

  /// 고른 이용권 (목록 없으면 null)
  PassOption? _selectedOption;

  /// 가격 조회 중 (버튼 문구 대신 로딩 상태)
  bool _isPriceLoading = true;

  /// 결제 창·복원 진행 중 (버튼 중복 탭 방지)
  bool _isBusy = false;

  /// 마지막 결제·복원 결과 안내 (구매 버튼 아래 한 줄)
  String? _statusMessage;

  /// 「PRO로 달라지는 점」 전부 펼쳤는지
  bool _isBenefitListExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.passOptions.firstOrNull;
    _loadPrices();
  }

  @override
  void dispose() {
    _isOfferSheetOpen = false;
    super.dispose();
  }

  /// 이용권 가격 조회 (목록 없으면 조회 없이 구매 불가)
  Future<void> _loadPrices() async {
    final productIds = [
      for (final option in widget.passOptions) option.productId,
    ];
    final priceByProductId = productIds.isEmpty
        ? const <String, PassPrice>{}
        : await ref.read(proPurchasePortProvider).loadPassPrices(productIds);
    if (!mounted) return;
    setState(() {
      _priceByProductId = priceByProductId;
      _isPriceLoading = false;
    });
  }

  /// 결제 또는 복원 실행 > 등급 갱신(시트가 닫혀도 실행) > 성공이면 닫기, 아니면 시트 안 안내
  Future<void> _run(Future<ProPurchaseOutcome> Function() action) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    final container = ProviderScope.containerOf(context);
    final outcome = await action();
    await refreshPlanIfPurchased(container, outcome);
    if (!mounted) return;
    if (outcome == ProPurchaseOutcome.success) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _isBusy = false;
      _statusMessage = proPurchaseStatusMessageOf(outcome);
    });
  }

  /// 이용 일수 > 칸 이름 (90일 > 3개월)
  static String _monthsLabelOf(PassOption option) =>
      '${toPassMonths(option.durationDays)}개월';

  /// 가격을 읽은 이용권 중 가장 짧은 것 (할인·권유 계산 기준, 없으면 null)
  PassOption? get _baseOption {
    final pricedOptions = widget.passOptions.where(
      (candidate) => _priceByProductId.containsKey(candidate.productId),
    );
    if (pricedOptions.isEmpty) return null;
    return pricedOptions.reduce(
      (shorter, candidate) =>
          candidate.durationDays < shorter.durationDays ? candidate : shorter,
    );
  }

  /// 가장 짧은 이용권 대비 할인 (가격 없음·할인 없음·기준 칸 자신이면 null)
  PassDiscount? _discountOf(PassOption option) {
    final baseOption = _baseOption;
    if (baseOption == null) return null;
    return calculatePassDiscount(
      longPassPrice: _priceByProductId[option.productId]?.rawPrice,
      longPassMonths: toPassMonths(option.durationDays),
      basePassPrice: _priceByProductId[baseOption.productId]?.rawPrice,
      basePassMonths: toPassMonths(baseOption.durationDays),
    );
  }

  /// 할인 전 값: 기준 이용권을 같은 기간만큼 샀을 때 (할인이 있을 때만)
  String? _undiscountedPriceOf(PassOption option) {
    final baseOption = _baseOption;
    final basePrice = baseOption == null
        ? null
        : _priceByProductId[baseOption.productId]?.rawPrice;
    if (baseOption == null || basePrice == null) return null;
    if (_discountOf(option) == null) return null;
    final total =
        basePrice *
        toPassMonths(option.durationDays) /
        toPassMonths(baseOption.durationDays);
    return '${formatThousands(total.round())}원';
  }

  /// 1개월(가장 짧은 칸)을 골랐을 때 가장 긴 이용권으로 바꾸면 아끼는 금액 > 권유 줄 (없으면 null)
  ({PassOption longOption, int savings})? get _upgradeSuggestion {
    final selectedOption = _selectedOption;
    final baseOption = _baseOption;
    if (selectedOption == null || selectedOption != baseOption) return null;
    final longOption = widget.passOptions.reduce(
      (longer, candidate) =>
          candidate.durationDays > longer.durationDays ? candidate : longer,
    );
    if (longOption == baseOption) return null;
    final savings = monthlySavingsOf(
      longPrice: _priceByProductId[longOption.productId]?.rawPrice,
      longMonths: toPassMonths(longOption.durationDays),
      basePrice: _priceByProductId[baseOption!.productId]?.rawPrice,
      baseMonths: toPassMonths(baseOption.durationDays),
    );
    if (savings == null) return null;
    return (longOption: longOption, savings: savings);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final port = ref.read(proPurchasePortProvider);
    final selectedOption = _selectedOption;
    final selectedPrice = selectedOption == null
        ? null
        : _priceByProductId[selectedOption.productId]?.displayPrice;
    final isPriceUnavailable = !_isPriceLoading && selectedPrice == null;
    final inlineMessage =
        _statusMessage ??
        (isPriceUnavailable ? proPurchaseUnavailableMessage : null);
    final selectedLabel = selectedOption == null
        ? _sheetTitle
        : '${_monthsLabelOf(selectedOption)} 이용권';
    final buyLabel = selectedPrice == null
        ? selectedLabel
        : '$selectedLabel $selectedPrice';
    final reason = widget.reason;
    final isIos = ref.read(targetPlatformProvider) == TargetPlatform.iOS;
    final schedule = widget.examSchedule;
    final daysUntil = schedule == null
        ? null
        : daysUntilExam(schedule.examDate);
    final freeCap = freeCapUntilExam(
      daysUntilExam: daysUntil,
      limit: widget.dailyFreeLimit,
    );
    final benefits = proBenefits(dailyFreeLimit: widget.dailyFreeLimit);
    final focusedIndex = widget.focusedBenefitIndex;
    final focusedBenefit =
        focusedIndex != null &&
            focusedIndex >= 0 &&
            focusedIndex < benefits.length
        ? benefits[focusedIndex]
        : null;
    final visibleBenefits = _isBenefitListExpanded
        ? benefits
        : benefits.take(_collapsedBenefitCount).toList();
    final upgrade = _upgradeSuggestion;
    final activeProExpiresAt = widget.activeProExpiresAt;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.md,
              0,
              PassqlSpacing.md,
              PassqlSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 「이용권」 글자 대신 숫자를 강조한 문장 제목 (스크린리더 머리글 역할)
                Semantics(
                  header: true,
                  child: Text.rich(
                    TextSpan(
                      style: PassqlTypography.title2.copyWith(
                        color: colors.label,
                      ),
                      children: [
                        if (daysUntil != null && daysUntil > 0)
                          TextSpan(text: '시험까지 $daysUntil일,\n'),
                        TextSpan(
                          text: '제한 없이',
                          style: TextStyle(color: colors.accentText),
                        ),
                        const TextSpan(text: ' 풀고 합격해요'),
                      ],
                    ),
                  ),
                ),
                if (freeCap != null) ...[
                  const SizedBox(height: PassqlSpacing.xxs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '무료로는 시험까지 랜덤 최대 $freeCap문제',
                          style: PassqlTypography.footnote.copyWith(
                            color: colors.secondaryLabel,
                          ),
                        ),
                      ),
                      Text(
                        '$daysUntil일 × ${widget.dailyFreeLimit}문제',
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
                if (reason != null) ...[
                  const SizedBox(height: PassqlSpacing.xs),
                  PassqlKeepAllText(
                    reason,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.accentText,
                    ),
                  ),
                ],
                if (focusedBenefit != null) ...[
                  const SizedBox(height: PassqlSpacing.sm),
                  _FocusedBenefitRow(
                    key: const Key('pro-offer-focused-benefit'),
                    benefit: focusedBenefit,
                  ),
                ],
                const SizedBox(height: PassqlSpacing.md),
                // 사면 받게 될 내 탑승권 (고른 이용권 만료일이 바로 바뀐다)
                PassqlPassTicket(
                  tier: PassqlPassTicketTier.pro,
                  destination: schedule == null
                      ? 'SQLD'
                      : '${schedule.certType} ${schedule.round}회',
                  fields: [
                    PassqlPassTicketField('승객', widget.nickname),
                    if (selectedOption != null)
                      PassqlPassTicketField(
                        '이용권',
                        '${_monthDayOf(selectedOption.expiresAtIfPurchased)}까지',
                        isHighlighted: true,
                      ),
                    if (schedule != null)
                      PassqlPassTicketField(
                        '시험일',
                        _monthDayOfText(schedule.examDate),
                      ),
                  ],
                  benefitIcons: [
                    for (final benefit in benefits)
                      (
                        icon: benefit.icon,
                        color: benefitColorOf(context, benefit),
                      ),
                  ],
                  stubLabel: 'PRO',
                  hasSweep: true,
                  hasHolo: true,
                  isFloating: true,
                  semanticLabel: selectedOption == null
                      ? 'passQL PRO PASS 미리보기'
                      : 'passQL PRO PASS 미리보기, ${formatDottedDate(selectedOption.expiresAtIfPurchased)}까지',
                ),
                if (activeProExpiresAt != null && selectedOption != null) ...[
                  const SizedBox(height: PassqlSpacing.sm),
                  Text(
                    '만료일 ${formatDottedDate(activeProExpiresAt)} > ${formatDottedDate(selectedOption.expiresAtIfPurchased)}',
                    textAlign: TextAlign.center,
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
                const SizedBox(height: PassqlSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PRO로 달라지는 점',
                        style: PassqlTypography.headline.copyWith(
                          color: colors.label,
                        ),
                      ),
                    ),
                    Text(
                      '${benefits.length}가지',
                      style: PassqlTypography.headline.copyWith(
                        color: colors.accentText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PassqlSpacing.xs),
                for (final benefit in visibleBenefits)
                  _BenefitRow(
                    benefit: benefit,
                    value: benefitFreeToProLabel(benefit),
                  ),
                // 3개보다 많으면 더 보기 <-> 접기 (펼친 뒤에도 다시 접을 수 있게)
                if (benefits.length > _collapsedBenefitCount)
                  PassqlPressable(
                    hasMinimumTouchTarget: true,
                    onTap: () => setState(
                      () => _isBenefitListExpanded = !_isBenefitListExpanded,
                    ),
                    semanticLabel: _isBenefitListExpanded
                        ? '혜택 접기'
                        : '${benefits.length - _collapsedBenefitCount}가지 더 보기',
                    child: Center(
                      child: Text(
                        _isBenefitListExpanded
                            ? '접기'
                            : '${benefits.length - _collapsedBenefitCount}가지 더 보기',
                        style: PassqlTypography.footnote.copyWith(
                          color: colors.secondaryLabel,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: PassqlSpacing.md),
                // 이용권 고르기 (서버 순서대로, 결제 중에는 바꿀 수 없음)
                for (final option in widget.passOptions) ...[
                  ProPassOptionTile(
                    label: _monthsLabelOf(option),
                    displayPrice:
                        _priceByProductId[option.productId]?.displayPrice,
                    ribbonLabel: _discountOf(option) == null
                        ? null
                        : '${_discountOf(option)!.discountPercent}% 할인',
                    undiscountedPrice: _undiscountedPriceOf(option),
                    monthlyLabel: _discountOf(option) == null
                        ? null
                        : '월 ${formatThousands(_discountOf(option)!.monthlyPrice)}원',
                    expiryLabel:
                        '${formatDottedDate(option.expiresAtIfPurchased)}까지',
                    isSelected: option == selectedOption,
                    onTap: _isBusy ? null : () => _select(option),
                  ),
                  const SizedBox(height: PassqlSpacing.xs),
                ],
                if (upgrade != null)
                  _UpgradeSuggestion(
                    savings: upgrade.savings,
                    monthlyShare: monthlyShareOf(
                      upgrade.savings,
                      toPassMonths(upgrade.longOption.durationDays),
                    ),
                    longLabel: _monthsLabelOf(upgrade.longOption),
                    onTap: _isBusy ? null : () => _select(upgrade.longOption),
                  ),
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
                  onTap: _isBusy ? null : () => _run(port.restorePurchases),
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
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                            ),
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
            ),
          ),
        ),
        // 구매 버튼은 스크롤 밖 아래에 고정 (시트가 길어도 늘 보이게)
        Padding(
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
              // 가격 조회 중·상품 없음·결제 중이면 누를 수 없음
              PassqlButton(
                label: buyLabel,
                isLoading: _isBusy || _isPriceLoading,
                onPressed: (selectedOption == null || selectedPrice == null)
                    ? null
                    : () => _run(
                        () => port.purchasePass(selectedOption.productId),
                      ),
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
        ),
      ],
    );
  }

  void _select(PassOption option) => setState(() {
    _selectedOption = option;
    _statusMessage = null;
  });
}

// 「PRO로 달라지는 점」 처음 보이는 줄 수 (가장 강한 이유 3개, 나머지는 더 보기)
const int _collapsedBenefitCount = 3;
// 혜택 줄 이름 칸 : 값 칸 폭 비율 (값이 가장 긴 '하루 10개 -> 제한 없음' 이 들어가는 폭)
const int _labelColumnFlex = 6;
const int _valueColumnFlex = 5;

String _monthDayOf(DateTime date) =>
    '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

String _monthDayOfText(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  return date == null ? isoDate : _monthDayOf(date);
}

/// 혜택 한 줄: 작은 색 타일 · 이름 · 점선 · 값 (네이버 혜택 시트 구조)
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.benefit, required this.value});

  final ProBenefit benefit;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
      child: Row(
        children: [
          PassqlIconTile(
            icon: benefit.icon,
            color: benefitColorOf(context, benefit),
            isCompact: true,
          ),
          const SizedBox(width: PassqlSpacing.xs),
          // 이름 칸(점선 포함)과 값 칸을 고정 비율로 나눠 모든 줄의 값이 같은 오른쪽 끝에 맞음
          // 큰 글자에서는 이름이 줄바꿈되고 점선은 남을 때만 그려짐
          Expanded(
            flex: _labelColumnFlex,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    benefit.label,
                    style: PassqlTypography.subheadline.copyWith(
                      color: colors.label,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PassqlSpacing.xs,
                    ),
                    child: CustomPaint(
                      painter: _DottedLinePainter(color: colors.separator),
                      child: const SizedBox(height: PassqlSize.hairline * 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _valueColumnFlex,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 탑승권 혜택 아이콘에서 들어왔을 때 그 혜택을 크게 (아이콘 + 이름 + 무료 → 프로 값)
class _FocusedBenefitRow extends StatelessWidget {
  const _FocusedBenefitRow({super.key, required this.benefit});

  final ProBenefit benefit;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(PassqlRadius.md),
      ),
      child: Row(
        children: [
          PassqlIconTile(
            icon: benefit.icon,
            color: benefitColorOf(context, benefit),
          ),
          const SizedBox(width: PassqlSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.label,
                  style: PassqlTypography.headline.copyWith(
                    color: colors.label,
                  ),
                ),
                Text(
                  benefitFreeToProLabel(benefit),
                  style: PassqlTypography.footnote.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 1개월을 골랐을 때 긴 이용권 권유 한 줄 (막지 않고 아끼는 금액만 보여 준다)
class _UpgradeSuggestion extends StatelessWidget {
  const _UpgradeSuggestion({
    required this.savings,
    required this.monthlyShare,
    required this.longLabel,
    required this.onTap,
  });

  final int savings;
  final int monthlyShare;
  final String longLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final message =
        '$longLabel로 바꾸면 ${formatThousands(savings)}원 아껴요 (월 ${formatThousands(monthlyShare)}원씩)';
    return PassqlPressable(
      onTap: onTap,
      semanticLabel: '$message, $longLabel로 바꾸기',
      child: Container(
        padding: const EdgeInsets.all(PassqlSpacing.sm),
        decoration: BoxDecoration(
          color: colors.accentTint,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: PassqlTypography.footnote.copyWith(color: colors.label),
              ),
            ),
            const SizedBox(width: PassqlSpacing.xs),
            Text(
              '$longLabel로 바꾸기 ›',
              style: PassqlTypography.footnoteSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 가로 점선 (혜택 이름과 값 사이)
class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});

  final Color color;

  // 점 간격
  static const double _dotGap = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += _dotGap) {
      canvas.drawCircle(Offset(x, size.height / 2), size.height / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
