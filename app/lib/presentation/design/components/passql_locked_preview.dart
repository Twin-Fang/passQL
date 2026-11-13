import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';
import 'passql_button.dart';
import 'passql_keep_all_text.dart';

/// 잠긴 기능 묶음: 흐린 가짜 미리보기 + 가운데 한 줄 + 알약 버튼 (#576)
/// 영역 어디를 눌러도 [onUnlock], 흐린 항목 자체는 눌리지 않음, 자물쇠 아이콘·떠 있는 카드 없음
class PassqlLockedPreview extends StatelessWidget {
  const PassqlLockedPreview({
    super.key,
    required this.preview,
    required this.caption,
    required this.onUnlock,
    this.unlockButtonLabel = unlockLabel,
    this.isCaptionAtTop = false,
  });

  /// 흐리게 깔 그럴듯한 가짜 미리보기 (서버의 잠긴 내용이 아님)
  final Widget preview;

  /// 잠긴 내용 한 줄 (예: 보기별 해설 · 함정 · 시험 팁)
  final String caption;
  final VoidCallback onUnlock;

  /// 알약 버튼 문구 (잠금 해제 후 앱에서 여는 자리처럼 뜻을 더 밝혀야 할 때만 바꿈)
  final String unlockButtonLabel;

  /// 한 줄·버튼을 위쪽에 둘지 (긴 미리보기에서 작은 화면도 스크롤 없이 보이게), 기본은 가운데
  final bool isCaptionAtTop;

  /// 알약 버튼 기본 문구 (모든 잠금 자리 공통)
  static const String unlockLabel = 'PRO로 보기';

  // 미리보기 투명도 (흐려도 윤곽이 남게)
  static const double _previewOpacity = 0.7;
  // 위아래로 옅어지는 덮개 진하기: 가장자리, 가운데 (문구·버튼이 떠 보이게)
  static const double _scrimEdgeAlpha = 0.15;
  static const double _scrimCenterAlpha = 0.55;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      button: true,
      label: '$caption, $unlockButtonLabel',
      // 하위 의미를 지우므로 누르기 동작을 여기서 다시 준다 (화면 낭독기)
      onTap: onUnlock,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onUnlock,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PassqlRadius.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: PassqlSize.lockedPreviewMinHeight,
            ),
            child: Stack(
              children: [
                // 흐린 미리보기 (입력 차단)
                IgnorePointer(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: PassqlSize.lockedPreviewBlurSigma,
                      sigmaY: PassqlSize.lockedPreviewBlurSigma,
                    ),
                    child: Opacity(opacity: _previewOpacity, child: preview),
                  ),
                ),
                // 덮개
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.background.withValues(alpha: _scrimEdgeAlpha),
                          colors.background.withValues(
                            alpha: _scrimCenterAlpha,
                          ),
                          colors.background.withValues(alpha: _scrimEdgeAlpha),
                        ],
                      ),
                    ),
                  ),
                ),
                // 한 줄 + 알약 버튼 (가운데 또는 위쪽)
                Positioned.fill(
                  child: Align(
                    alignment: isCaptionAtTop
                        ? Alignment.topCenter
                        : Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        PassqlSpacing.sm,
                        isCaptionAtTop ? PassqlSpacing.xxl : PassqlSpacing.sm,
                        PassqlSpacing.sm,
                        PassqlSpacing.sm,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PassqlKeepAllText(
                            caption,
                            textAlign: TextAlign.center,
                            style: PassqlTypography.subheadlineSemibold
                                .copyWith(color: colors.label),
                          ),
                          const SizedBox(height: PassqlSpacing.xs),
                          PassqlButton(
                            label: unlockButtonLabel,
                            onPressed: onUnlock,
                            size: PassqlButtonSize.small,
                            isFullWidth: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
