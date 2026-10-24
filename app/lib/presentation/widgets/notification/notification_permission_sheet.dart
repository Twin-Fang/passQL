import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'notification_permission_texts.dart';

/// 알림 권한 사전 안내 시트: 대표 아이콘 > 제목·설명 > 받는 소식 3가지 > "알림 받기"(true) / "나중에"(false)
/// 닫기 X 없음: 손잡이 드래그·바깥 탭·"나중에"로 닫힘 (모두 false). "알림 받기"를 눌러야만 시스템 권한 창이 뜸
Future<bool> showNotificationPermissionSheet(BuildContext context) async {
  final isAccepted = await showPassqlSheet<bool>(
    context,
    builder: (sheetContext) => const NotificationPermissionSheetBody(),
  );
  return isAccepted ?? false;
}

/// 시트 본문: 안내는 스크롤(큰 글자 대응), 버튼 2개는 아래 고정
class NotificationPermissionSheetBody extends StatelessWidget {
  const NotificationPermissionSheetBody({super.key});

  /// 받는 소식 줄별 아이콘 (NotificationPermissionTexts.receivedNewsLines 순서와 같게, 같은 타일·같은 색)
  static const List<IconData> lineIcons = [
    CupertinoIcons.speaker_2_fill,
    CupertinoIcons.flag_fill,
    CupertinoIcons.calendar,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              PassqlSpacing.lg,
              0,
              PassqlSpacing.lg,
              PassqlSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _HeroIcon(),
                const SizedBox(height: PassqlSpacing.md),
                const _Heading(),
                const SizedBox(height: PassqlSpacing.xl),
                for (final (lineIndex, line)
                    in NotificationPermissionTexts.receivedNewsLines.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: PassqlSpacing.sm),
                    child: _BenefitRow(icon: lineIcons[lineIndex], text: line),
                  ),
              ],
            ),
          ),
        ),
        const _Actions(),
      ],
    );
  }
}

/// 맨 위 대표 아이콘: 브랜드 색 옅은 원 + 종
class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Center(
      child: Container(
        width: PassqlSize.sheetHeroCircle,
        height: PassqlSize.sheetHeroCircle,
        decoration: BoxDecoration(
          color: colors.accentTint,
          shape: BoxShape.circle,
        ),
        child: Icon(
          CupertinoIcons.bell_fill,
          size: PassqlIconSize.sheetHero,
          color: colors.accent,
        ),
      ),
    );
  }
}

/// 제목·설명 (가운데 정렬, 단어 단위 줄바꿈)
class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      children: [
        Semantics(
          header: true,
          child: PassqlKeepAllText(
            NotificationPermissionTexts.sheetTitle,
            textAlign: TextAlign.center,
            style: PassqlTypography.title3.copyWith(color: colors.label),
          ),
        ),
        const SizedBox(height: PassqlSpacing.xs),
        PassqlKeepAllText(
          NotificationPermissionTexts.sheetDescription,
          textAlign: TextAlign.center,
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}

/// 받는 소식 1줄: 같은 크기·같은 색 아이콘 타일 + 글자 (타일 폭 고정 > 글자 시작선 일치)
class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Row(
      children: [
        PassqlIconTile(icon: icon, color: colors.accent),
        const SizedBox(width: PassqlSpacing.sm),
        Expanded(
          child: PassqlKeepAllText(
            text,
            style: PassqlTypography.body.copyWith(color: colors.label),
          ),
        ),
      ],
    );
  }
}

/// 하단 고정 버튼: 주 버튼 "알림 받기" + 보조 글자 버튼 "나중에" + 선택 안내
class _Actions extends StatelessWidget {
  const _Actions();

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PassqlSpacing.lg,
        0,
        PassqlSpacing.lg,
        PassqlSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PassqlKeepAllText(
            NotificationPermissionTexts.optionalNotice,
            textAlign: TextAlign.center,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
          const SizedBox(height: PassqlSpacing.sm),
          PassqlButton(
            label: NotificationPermissionTexts.acceptLabel,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: PassqlSpacing.xxs),
          PassqlButton(
            label: NotificationPermissionTexts.laterLabel,
            variant: PassqlButtonVariant.plain,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
