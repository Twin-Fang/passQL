import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/pro_purchase_port.dart';
import '../../../core/utils/date_format.dart';
import '../../design/design.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';
import 'pro_plan_comparison_table.dart';
import 'pro_purchase_feedback.dart';

/// 시트가 떠 있는가: 한 번에 한 장만 (빠른 두 번 탭 방지)
/// 시트 본문이 사라질 때(닫힘 연출 끝·화면 해체) 내려감
bool _isOfferSheetOpen = false;

/// 시트 제목·구매 버튼 기본 문구
const String _sheetTitle = '회차 패스';
const String _restoreLabel = '이미 구매했나요? 복원하기';

/// 프로 안내 시트 (모든 진입점이 공유하는 한 장): 제목 > 부제 > 들어온 이유 > 비교표 > 구매 > 복원
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
  try {
    final isPurchased = await showPassqlSheet<bool>(
      context,
      hasCloseButton: false,
      builder: (_) => _ProOfferSheetBody(
        purchasableUntil: knownPlan?.purchasableUntil,
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
    required this.purchasableUntil,
    required this.dailyFreeLimit,
    required this.reason,
  });

  final DateTime? purchasableUntil;
  final int dailyFreeLimit;
  final String? reason;

  @override
  ConsumerState<_ProOfferSheetBody> createState() => _ProOfferSheetBodyState();
}

class _ProOfferSheetBodyState extends ConsumerState<_ProOfferSheetBody> {
  /// 스토어 가격 문자열 (null = 상품을 못 읽음)
  String? _price;

  /// 가격 조회 중 (버튼 문구 대신 로딩 상태)
  bool _isPriceLoading = true;

  /// 결제 창·복원 진행 중 (버튼 중복 탭 방지)
  bool _isBusy = false;

  /// 마지막 결제·복원 결과 안내 (구매 버튼 아래 한 줄)
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  @override
  void dispose() {
    _isOfferSheetOpen = false;
    super.dispose();
  }

  Future<void> _loadPrice() async {
    final price = await ref.read(proPurchasePortProvider).loadExamPassPrice();
    if (!mounted) return;
    setState(() {
      _price = price;
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

  String get _subtitle {
    final examDate = widget.purchasableUntil;
    return examDate == null
        ? '다음 SQLD 시험일까지 · 자동 결제 없음'
        : '다음 SQLD 시험일(${formatDottedDate(examDate)})까지 · 자동 결제 없음';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final port = ref.read(proPurchasePortProvider);
    final isPriceUnavailable = !_isPriceLoading && _price == null;
    final inlineMessage =
        _statusMessage ??
        (isPriceUnavailable ? proPurchaseUnavailableMessage : null);
    final buyLabel = _price == null ? _sheetTitle : '$_sheetTitle $_price';
    final reason = widget.reason;
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
                color: colors.accent,
              ),
            ),
          ],
          const SizedBox(height: PassqlSpacing.md),
          ProPlanComparisonTable(dailyFreeLimit: widget.dailyFreeLimit),
          const SizedBox(height: PassqlSpacing.md),
          // 구매 버튼: 가격 조회 중·상품 없음·결제 중이면 누를 수 없음
          PassqlButton(
            label: buyLabel,
            isLoading: _isBusy || _isPriceLoading,
            onPressed: (_price == null)
                ? null
                : () => _run(port.purchaseExamPass),
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
