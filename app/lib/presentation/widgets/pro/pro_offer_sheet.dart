import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pass_option_pricing.dart';
import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/app_clock.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/home_providers.dart';
import '../../providers/plan_providers.dart';
import '../../providers/profile_pass_providers.dart';
import '../../providers/settings_providers.dart';
import '../common/app_toast.dart';
import 'pro_benefits.dart';
import 'pro_offer_benefit_list.dart';
import 'pro_offer_buy_bar.dart';
import 'pro_offer_headline.dart';
import 'pro_offer_pass_option_list.dart';
import 'pro_offer_payment_notes.dart';
import 'pro_offer_ticket_preview.dart';
import 'pro_purchase_feedback.dart';

/// 시트가 떠 있는가: 한 번에 한 장만 (빠른 두 번 탭 방지)
/// 시트 본문이 사라질 때(닫힘 연출 끝·화면 해체) 내려감
bool _isOfferSheetOpen = false;

/// 시트 결과 2종 (호출부가 이어서 할 일을 정함, #808)
/// 광고 보너스는 한도 화면이 맡음 (DailyLimitRewardView, #963)
enum ProOfferSheetOutcome {
  dismissed, // 그냥 닫음 또는 이미 다른 시트가 떠 있어 열지 않음
  purchased, // 이용권 구매·복원 성공
}

/// 구매 버튼 기본 문구(이용권 목록이 없을 때)
const String _sheetTitle = '이용권';

/// 프로 안내 시트 (모든 진입점이 공유하는 한 장, #749): 문장 제목 > 기간 줄 > 강조 혜택 > 내 이름 PRO 탑승권 > 달라지는 점 > 이용권 고르기(1개월이면 3개월 권유) > 복원 > 각주 + 아래 고정 구매 버튼
/// 성공 > 시트 닫힘 > 호출 화면에서 토스트, 그 외 결과는 시트 안 한 줄 (확인 중에 닫아도 확인 결과로 토스트·연출·호출부 재시도)
Future<ProOfferSheetOutcome> showProOfferSheet(
  BuildContext context,
  WidgetRef ref, {
  // 탑승권 혜택 아이콘에서 열었을 때 그 혜택 순서(proBenefits 기준) > 시트가 그 줄을 강조 (#749)
  int? focusedBenefitIndex,
}) async {
  if (_isOfferSheetOpen) return ProOfferSheetOutcome.dismissed;
  _isOfferSheetOpen = true;
  final knownPlan = ref.read(knownPlanProvider);
  final proExpiresAt = knownPlan?.proExpiresAt;
  // 지금 프로 이용 중일 때만 현재 만료일 > 연장 시트 (제목·미리보기·완료 문구가 연장용)
  final activeProExpiresAt =
      proExpiresAt != null && proExpiresAt.isAfter(AppClock.now())
      ? proExpiresAt
      : null;
  // 시트가 닫힐 때 호출 화면이 이미 사라졌을 수 있어 ref 는 기다리기 전에 읽어 둔다
  final revealNotifier = ref.read(profilePassRevealPendingProvider.notifier);
  // 시트 안에서 마지막으로 시작한 결제 확인 (닫힌 뒤에도 끝까지 기다림)
  Future<ProOfferSheetOutcome>? pendingConfirmation;
  try {
    final closedOutcome = await showPassqlSheet<ProOfferSheetOutcome>(
      context,
      builder: (_) => _ProOfferSheetBody(
        // 등급 응답 이용권 목록 (서버 순서 3개월 먼저 > 첫 칸 기본 선택)
        passOptions: knownPlan?.passOptions ?? const [],
        activeProExpiresAt: activeProExpiresAt,
        dailyFreeLimit: knownPlan?.dailyFreeLimit ?? 0,
        onConfirmationStarted: (confirmation) =>
            pendingConfirmation = confirmation,
        focusedBenefitIndex: focusedBenefitIndex,
      ),
    );
    final outcome =
        closedOutcome ??
        await _awaitConfirmationAfterDismiss(pendingConfirmation);
    if (outcome == ProOfferSheetOutcome.purchased) {
      // 연장은 이미 PRO 탑승권이라 무료 > 프로 연출 없음
      if (activeProExpiresAt == null) {
        // 어느 진입점에서 샀든 다음 프로필 진입 때 탑승권 연출을 한 번 보여 준다 (#749)
        await revealNotifier.markPending();
      }
      if (context.mounted) {
        showAppToast(
          context,
          activeProExpiresAt == null
              ? proPurchaseSucceededMessage
              : proExtendSucceededMessage,
        );
      }
      return ProOfferSheetOutcome.purchased;
    }
    return ProOfferSheetOutcome.dismissed;
  } catch (_) {
    // 시트를 띄우지 못한 경우만 여기서 내림
    _isOfferSheetOpen = false;
    rethrow;
  }
}

/// 그냥 닫힘 > 진행 중이던 확인 결과 (없으면 dismissed)
Future<ProOfferSheetOutcome> _awaitConfirmationAfterDismiss(
  Future<ProOfferSheetOutcome>? pendingConfirmation,
) async => await pendingConfirmation ?? ProOfferSheetOutcome.dismissed;

/// 확인 결과 > 시트 결과 (실패·예외는 dismissed, 기다리는 쪽이 없어도 처리 안 된 오류를 남기지 않게)
Future<ProOfferSheetOutcome> _toSheetOutcome<T>(
  Future<T> confirmation, {
  required bool Function(T result) isUnlocked,
  required ProOfferSheetOutcome unlockedOutcome,
}) => confirmation
    .then(
      (result) =>
          isUnlocked(result) ? unlockedOutcome : ProOfferSheetOutcome.dismissed,
    )
    .catchError((Object _) => ProOfferSheetOutcome.dismissed);

class _ProOfferSheetBody extends ConsumerStatefulWidget {
  const _ProOfferSheetBody({
    required this.passOptions,
    required this.activeProExpiresAt,
    required this.dailyFreeLimit,
    required this.onConfirmationStarted,
    required this.focusedBenefitIndex,
  });

  final List<PassOption> passOptions;

  /// 이용 중인 프로 만료일 (무료·만료면 null)
  final DateTime? activeProExpiresAt;
  final int dailyFreeLimit;

  /// 결제 확인 시작 (시트가 닫혀도 호출부가 결과를 기다림)
  final void Function(Future<ProOfferSheetOutcome> confirmation)
  onConfirmationStarted;

  /// 탑승권 혜택 아이콘에서 열었으면 그 혜택 순서 (proBenefits 기준)
  final int? focusedBenefitIndex;

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
    final purchaseConfirmation = _confirmPurchase(container, action);
    widget.onConfirmationStarted(
      _toSheetOutcome(
        purchaseConfirmation,
        isUnlocked: (outcome) => outcome == ProPurchaseOutcome.success,
        unlockedOutcome: ProOfferSheetOutcome.purchased,
      ),
    );
    final outcome = await purchaseConfirmation;
    if (!mounted) return;
    if (outcome == ProPurchaseOutcome.success) {
      _closeSheetWith(ProOfferSheetOutcome.purchased);
      return;
    }
    setState(() {
      _isBusy = false;
      _statusMessage = proPurchaseStatusMessageOf(outcome);
    });
  }

  /// 결제·복원 > 성공이면 등급 다시 받기 (시트와 무관하게 끝까지)
  static Future<ProPurchaseOutcome> _confirmPurchase(
    ProviderContainer container,
    Future<ProPurchaseOutcome> Function() action,
  ) async {
    final outcome = await action();
    await refreshPlanIfPurchased(container, outcome);
    return outcome;
  }

  /// 이용권 목록 + 스토어 가격 계산 (기준 이용권·할인·권유)
  PassOptionPricing<PassOption> get _pricing => PassOptionPricing(
    options: widget.passOptions,
    priceByProductId: _priceByProductId,
    productIdOf: (option) => option.productId,
    durationDaysOf: (option) => option.durationDays,
  );

  /// 탑승권 혜택 아이콘에서 열었으면 그 혜택 (순서가 범위 밖이면 null)
  ProBenefit? _focusedBenefitOf(List<ProBenefit> benefits) {
    final focusedIndex = widget.focusedBenefitIndex;
    if (focusedIndex == null ||
        focusedIndex < 0 ||
        focusedIndex >= benefits.length) {
      return null;
    }
    return benefits[focusedIndex];
  }

  @override
  Widget build(BuildContext context) {
    final port = ref.read(proPurchasePortProvider);
    final selectedOption = _selectedOption;
    final selectedPrice = selectedOption == null
        ? null
        : _priceByProductId[selectedOption.productId]?.displayPrice;
    final isPriceUnavailable = !_isPriceLoading && selectedPrice == null;
    final selectedLabel = selectedOption == null
        ? _sheetTitle
        : '${passMonthsLabelOf(selectedOption)} 이용권';
    // 시험 일정: 닉네임과 같이 시트가 떠 있는 동안 도착하면 채움 (결과 화면에서 바로 열 때 등)
    final schedule = ref.watch(examScheduleProvider).valueOrNull;
    final daysUntil = schedule == null
        ? null
        : daysUntilExam(schedule.examDate);
    final benefits = proBenefits(dailyFreeLimit: widget.dailyFreeLimit);
    final activeProExpiresAt = widget.activeProExpiresAt;
    final isExtending = activeProExpiresAt != null;
    // 승객 칸: 시트가 떠 있는 동안 닉네임이 도착하면 채움 (홈에서 바로 열면 아직 안 불러온 상태)
    final nickname = ref.watch(settingsDataProvider).valueOrNull?.nickname ?? '';

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
                ProOfferHeadline(
                  daysUntilExam: daysUntil,
                  activeProExpiresAt: activeProExpiresAt,
                  // 연장이면 무료 최대치 줄 없음 (이미 제한 없이 푸는 중)
                  freeCap: isExtending
                      ? null
                      : freeCapUntilExam(
                          daysUntilExam: daysUntil,
                          limit: widget.dailyFreeLimit,
                        ),
                  focusedBenefit: _focusedBenefitOf(benefits),
                ),
                const SizedBox(height: PassqlSpacing.md),
                ProOfferTicketPreview(
                  nickname: nickname,
                  examSchedule: schedule,
                  selectedOption: selectedOption,
                  benefits: benefits,
                  activeProExpiresAt: activeProExpiresAt,
                ),
                // 「PRO로 달라지는 점」은 무료 회원용 (연장이면 이미 쓰는 혜택)
                if (!isExtending) ...[
                  const SizedBox(height: PassqlSpacing.xl),
                  ProOfferBenefitList(benefits: benefits),
                ],
                const SizedBox(height: PassqlSpacing.md),
                // 이용권 고르기 (서버 순서대로, 결제 중에는 바꿀 수 없음)
                ProOfferPassOptionList(
                  pricing: _pricing,
                  selectedOption: selectedOption,
                  onSelect: _isBusy ? null : _select,
                ),
                ProOfferPaymentNotes(
                  isIos: ref.read(targetPlatformProvider) == TargetPlatform.iOS,
                  onRestoreTap: _isBusy
                      ? null
                      : () => _run(port.restorePurchases),
                ),
              ],
            ),
          ),
        ),
        // 구매 버튼은 스크롤 밖 아래에 고정 (시트가 길어도 늘 보이게)
        ProOfferBuyBar(
          label: selectedPrice == null
              ? selectedLabel
              : '$selectedLabel $selectedPrice',
          isLoading: _isBusy || _isPriceLoading,
          onPressed: (selectedOption == null || selectedPrice == null)
              ? null
              : () => _run(() => port.purchasePass(selectedOption.productId)),
          inlineMessage:
              _statusMessage ??
              (isPriceUnavailable ? proPurchaseUnavailableMessage : null),
        ),
      ],
    );
  }

  /// 시트가 맨 위일 때만 닫기 (이미 닫히는 중이면 pop 이 아래 화면을 닫음 > 결과는 확인 Future 로 전달됨)
  void _closeSheetWith(ProOfferSheetOutcome outcome) {
    if (ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.of(context).pop(outcome);
  }

  void _select(PassOption option) => setState(() {
    _selectedOption = option;
    _statusMessage = null;
  });
}
