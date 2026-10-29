import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pass_option_pricing.dart';
import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/exam_dday.dart';
import '../../../core/utils/profile_pass_values.dart';
import '../../../data/models/exam/exam_schedule_response.dart';
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

/// 구매 버튼 기본 문구(이용권 목록이 없을 때)
const String _sheetTitle = '이용권';

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
    final schedule = widget.examSchedule;
    final daysUntil = schedule == null
        ? null
        : daysUntilExam(schedule.examDate);
    final benefits = proBenefits(dailyFreeLimit: widget.dailyFreeLimit);

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
                  freeCap: freeCapUntilExam(
                    daysUntilExam: daysUntil,
                    limit: widget.dailyFreeLimit,
                  ),
                  dailyFreeLimit: widget.dailyFreeLimit,
                  reason: widget.reason,
                  focusedBenefit: _focusedBenefitOf(benefits),
                ),
                const SizedBox(height: PassqlSpacing.md),
                ProOfferTicketPreview(
                  nickname: widget.nickname,
                  examSchedule: schedule,
                  selectedOption: selectedOption,
                  benefits: benefits,
                  activeProExpiresAt: widget.activeProExpiresAt,
                ),
                const SizedBox(height: PassqlSpacing.xl),
                ProOfferBenefitList(benefits: benefits),
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

  void _select(PassOption option) => setState(() {
    _selectedOption = option;
    _statusMessage = null;
  });
}
