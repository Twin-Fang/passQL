import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/billing/promo_code_redemption_port.dart';
import '../../design/design.dart';
import '../../providers/pro_ui_providers.dart';
import '../../providers/plan_providers.dart';
import '../common/app_toast.dart';

// 코드 입력 시작 실패 안내 (스토어 화면을 열지 못함·쓸 수 없는 환경)
const String _openFailedMessage = '코드 입력 화면을 열지 못했어요';
const String _unavailableMessage = '지금은 코드를 쓸 수 없어요';
// Play 프로모션 코드 최대 길이 (스토어 코드는 영문·숫자 20자 안팎, 여유 있게)
const int _maximumCodeLength = 40;

/// 계정 화면 `프로모션 코드` 묶음 (#816): 스토어 코드만 (자체 서버 코드 없음)
/// Android = 코드 입력 + 적용 > Play 코드 화면, iOS = App Store 코드 입력 시트. 적용 결과는 구매 스트림·앱 복귀 갱신이 반영
/// 결제 UI 대상(무료 잠금 UI 또는 프로 표시)일 때만
class PromoCodeSection extends ConsumerStatefulWidget {
  const PromoCodeSection({super.key});

  @override
  ConsumerState<PromoCodeSection> createState() => _PromoCodeSectionState();
}

class _PromoCodeSectionState extends ConsumerState<PromoCodeSection> {
  final TextEditingController _codeController = TextEditingController();

  /// 스토어 화면 여는 중 (중복 탭 방지)
  bool _isOpening = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 스토어 코드 입력 시작 > 실패면 토스트 (열림은 스토어 화면이 안내)
  Future<void> _startRedemption() async {
    if (_isOpening) return;
    setState(() => _isOpening = true);
    final outcome = await ref
        .read(promoCodeRedemptionPortProvider)
        .startRedemption(code: _codeController.text);
    if (!mounted) return;
    setState(() => _isOpening = false);
    final message = switch (outcome) {
      PromoCodeRedemptionOutcome.opened => null,
      PromoCodeRedemptionOutcome.failed => _openFailedMessage,
      PromoCodeRedemptionOutcome.unavailable => _unavailableMessage,
    };
    if (message != null) showAppToast(context, message);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isBillingUiTargetProvider)) return const SizedBox.shrink();
    final isIos = ref.watch(targetPlatformProvider) == TargetPlatform.iOS;
    final isCodeEntryInApp = ref
        .watch(promoCodeRedemptionPortProvider)
        .isCodeEntryInApp;
    return PassqlGroupedSection(
      header: '프로모션 코드',
      footer: isIos
          ? 'App Store 코드 입력 화면이 열려요'
          : '받은 코드를 넣으면 Google Play 코드 입력 화면이 열려요',
      children: [
        if (isCodeEntryInApp)
          _CodeEntryRow(
            controller: _codeController,
            isOpening: _isOpening,
            onApply: _startRedemption,
          )
        else
          PassqlListRow(
            title: '코드 입력하기',
            hasChevron: true,
            onTap: _isOpening ? null : _startRedemption,
          ),
      ],
    );
  }
}

/// Android 코드 입력 줄: 입력 칸 + 적용 버튼 (빈 칸이면 적용 불가)
class _CodeEntryRow extends StatelessWidget {
  const _CodeEntryRow({
    required this.controller,
    required this.isOpening,
    required this.onApply,
  });

  final TextEditingController controller;
  final bool isOpening;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.all(PassqlSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: PassqlSpacing.md,
                vertical: PassqlSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.fill,
                borderRadius: BorderRadius.circular(PassqlRadius.md),
              ),
              child: TextField(
                controller: controller,
                maxLength: _maximumCodeLength,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                style: PassqlTypography.body.copyWith(color: colors.label),
                cursorColor: colors.accent,
                decoration: InputDecoration.collapsed(
                  hintText: '코드를 입력하세요',
                  hintStyle: PassqlTypography.body.copyWith(
                    color: colors.secondaryLabel,
                  ),
                ).copyWith(counterText: ''),
              ),
            ),
          ),
          const SizedBox(width: PassqlSpacing.xs),
          // 입력값이 바뀔 때마다 적용 버튼 활성 여부만 다시 그림
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) => PassqlButton(
              label: '적용',
              isFullWidth: false,
              isLoading: isOpening,
              onPressed: value.text.trim().isEmpty ? null : onApply,
            ),
          ),
        ],
      ),
    );
  }
}
