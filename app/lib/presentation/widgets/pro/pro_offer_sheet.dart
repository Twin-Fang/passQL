import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pass_discount.dart';
import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/number_format.dart';
import '../../../data/models/member/member_plan_response.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';
import 'pro_pass_option_tile.dart';
import 'pro_plan_comparison_table.dart';
import 'pro_purchase_feedback.dart';

/// 시트가 떠 있는가: 한 번에 한 장만 (빠른 두 번 탭 방지)
/// 시트 본문이 사라질 때(닫힘 연출 끝·화면 해체) 내려감
bool _isOfferSheetOpen = false;

/// 시트 제목·구매 버튼 기본 문구
const String _sheetTitle = '이용권';
const String _restoreLabel = '이미 구매했나요? 복원하기';
const String _noAutoRenewLabel = '자동 결제 없음';

/// iOS 결제 수단 안내 (App Store 결제 시트 안내, 다른 결제 경로 언급 금지)
const String _appleIdPaymentNotice = '구매는 Apple ID 계정으로 결제됩니다.';

/// 프로 안내 시트 (모든 진입점이 공유하는 한 장): 제목 > 만료일 미리보기 > 들어온 이유 > 비교표 > 이용권 고르기 > 구매 > (iOS) Apple ID 결제 안내 > 복원
/// 이용권 목록은 등급 응답 passOptions (서버 순서 3개월 먼저 > 첫 칸 기본 선택)
/// [reason]: 진입점별 한 줄 (예: 오늘 무료 10문제를 다 풀었어요)
/// 성공 > 시트 닫힘 > 호출 화면에서 토스트, 그 외 결과는 시트 안 한 줄
Future<void> showProOfferSheet(
  BuildContext context,
  WidgetRef ref, {
  String? reason,
}) async {
  if (_isOfferSheetOpen) return;
  _isOfferSheetOpen = true;
  final knownPlan = ref.read(knownPlanProvider);
  final proExpiresAt = knownPlan?.proExpiresAt;
  try {
    final isPurchased = await showPassqlSheet<bool>(
      context,
      hasCloseButton: false,
      builder: (_) => _ProOfferSheetBody(
        passOptions: knownPlan?.passOptions ?? const [],
        // 지금 프로 이용 중일 때만 현재 만료일 > 연장 미리보기
        activeProExpiresAt:
            proExpiresAt != null && proExpiresAt.isAfter(DateTime.now())
            ? proExpiresAt
            : null,
        dailyFreeLimit: knownPlan?.dailyFreeLimit ?? 0,
        reason: reason,
      ),
    );
    if (isPurchased == true && context.mounted) {
      showAppToast(context, proPurchaseSucceededMessage);
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
  });

  final List<PassOption> passOptions;

  /// 이용 중인 프로 만료일 (무료·만료면 null)
  final DateTime? activeProExpiresAt;
  final int dailyFreeLimit;
  final String? reason;

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

  /// 고른 이용권 만료일 미리보기: 이용 중 "만료일 A > B", 신규 "B까지" + 자동 결제 없음
  String get _subtitle {
    final selectedOption = _selectedOption;
    if (selectedOption == null) return _noAutoRenewLabel;
    final newExpiry = formatDottedDate(selectedOption.expiresAtIfPurchased);
    final activeProExpiresAt = widget.activeProExpiresAt;
    final expiryPreview = activeProExpiresAt == null
        ? '$newExpiry까지'
        : '만료일 ${formatDottedDate(activeProExpiresAt)} > $newExpiry';
    return '$expiryPreview · $_noAutoRenewLabel';
  }

  /// 이용 일수 > 칸 이름 (90일 > 3개월 이용권)
  static String _optionLabelOf(PassOption option) =>
      '${toPassMonths(option.durationDays)}개월 이용권';

  /// 가장 짧은 이용권 대비 할인 배지 문구 (가격 없음·할인 없음·기준 칸 자신이면 null)
  String? _discountLabelOf(PassOption option) {
    final pricedOptions = widget.passOptions.where(
      (candidate) => _priceByProductId.containsKey(candidate.productId),
    );
    if (pricedOptions.isEmpty) return null;
    final baseOption = pricedOptions.reduce(
      (shorter, candidate) =>
          candidate.durationDays < shorter.durationDays ? candidate : shorter,
    );
    final discount = calculatePassDiscount(
      longPassPrice: _priceByProductId[option.productId]?.rawPrice,
      longPassMonths: toPassMonths(option.durationDays),
      basePassPrice: _priceByProductId[baseOption.productId]?.rawPrice,
      basePassMonths: toPassMonths(baseOption.durationDays),
    );
    if (discount == null) return null;
    return '${discount.discountPercent}% 할인 · 월 ${formatThousands(discount.monthlyPrice)}원';
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
        : _optionLabelOf(selectedOption);
    final buyLabel = selectedPrice == null
        ? selectedLabel
        : '$selectedLabel $selectedPrice';
    final reason = widget.reason;
    final isIos = ref.read(targetPlatformProvider) == TargetPlatform.iOS;
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
          // 제목 + PRO 칩
          Row(
            children: [
              Text(
                _sheetTitle,
                style: PassqlTypography.title2.copyWith(color: colors.label),
              ),
              const SizedBox(width: PassqlSpacing.xs),
              const PassqlPlanChip(isPro: true),
            ],
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          PassqlKeepAllText(
            _subtitle,
            style: PassqlTypography.subheadline.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          if (reason != null) ...[
            const SizedBox(height: PassqlSpacing.xs),
            PassqlKeepAllText(
              reason,
              style: PassqlTypography.subheadlineSemibold.copyWith(
                color: colors.accentText,
              ),
            ),
          ],
          const SizedBox(height: PassqlSpacing.md),
          ProPlanComparisonTable(dailyFreeLimit: widget.dailyFreeLimit),
          const SizedBox(height: PassqlSpacing.md),
          // 이용권 고르기 (서버 순서대로, 결제 중에는 바꿀 수 없음)
          for (final option in widget.passOptions) ...[
            ProPassOptionTile(
              label: _optionLabelOf(option),
              displayPrice: _priceByProductId[option.productId]?.displayPrice,
              discountLabel: _discountLabelOf(option),
              isSelected: option == selectedOption,
              onTap: _isBusy
                  ? null
                  : () => setState(() {
                      _selectedOption = option;
                      _statusMessage = null;
                    }),
            ),
            const SizedBox(height: PassqlSpacing.xs),
          ],
          if (widget.passOptions.isNotEmpty)
            const SizedBox(height: PassqlSpacing.xs),
          // 구매 버튼: 가격 조회 중·상품 없음·결제 중이면 누를 수 없음
          PassqlButton(
            label: buyLabel,
            isLoading: _isBusy || _isPriceLoading,
            onPressed: (selectedOption == null || selectedPrice == null)
                ? null
                : () => _run(() => port.purchasePass(selectedOption.productId)),
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
          PassqlButton(
            label: _restoreLabel,
            variant: PassqlButtonVariant.plain,
            size: PassqlButtonSize.regular,
            onPressed: _isBusy ? null : () => _run(port.restorePurchases),
          ),
        ],
      ),
    );
  }
}
