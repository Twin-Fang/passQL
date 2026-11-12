import 'package:flutter/cupertino.dart';

import '../../design/design.dart';
import 'notification_permission_texts.dart';

/// 알림 권한 사전 안내 시트 (#1041 B안): 대표 아이콘 > 제목·설명 > 실제 알림 미리보기 2개 > 종류 요약 > "알림 받기"(true) / "나중에"(false)
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
                const SizedBox(height: PassqlSpacing.lg),
                // 받게 될 알림을 잠금화면 알림 모양으로 미리 보여 줌
                for (final notification
                    in NotificationPermissionTexts.previewNotifications)
                  Padding(
                    padding: const EdgeInsets.only(bottom: PassqlSpacing.xs),
                    child: _NotificationPreviewCard(
                      title: notification.title,
                      body: notification.body,
                      receivedAt: notification.receivedAt,
                    ),
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

/// 알림 미리보기 1개: 앱 표시(종 타일 + passQL + 받은 때) > 굵은 제목 > 본문
class _NotificationPreviewCard extends StatelessWidget {
  const _NotificationPreviewCard({
    required this.title,
    required this.body,
    required this.receivedAt,
  });

  final String title;
  final String body;
  final String receivedAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Semantics(
      container: true,
      label: '알림 예시, $title, $body',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // 카드·시트 위 옅은 칸 (라이트·다크 모두 회색 채움)
          color: colors.fill,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PassqlSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PassqlIconTile(
                    icon: CupertinoIcons.bell_fill,
                    color: colors.accent,
                    isCompact: true,
                  ),
                  const SizedBox(width: PassqlSpacing.xs),
                  Expanded(
                    child: Text(
                      'passQL',
                      style: PassqlTypography.footnote.copyWith(
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ),
                  Text(
                    receivedAt,
                    style: PassqlTypography.footnote.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: PassqlSpacing.xs),
              PassqlKeepAllText(
                title,
                style: PassqlTypography.subheadlineSemibold.copyWith(
                  color: colors.label,
                ),
              ),
              PassqlKeepAllText(
                body,
                style: PassqlTypography.subheadline.copyWith(
                  color: colors.secondaryLabel,
                ),
              ),
            ],
          ),
        ),
      ),
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
            NotificationPermissionTexts.sentKindsSummary,
            textAlign: TextAlign.center,
            style: PassqlTypography.footnote.copyWith(
              color: colors.secondaryLabel,
            ),
          ),
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
