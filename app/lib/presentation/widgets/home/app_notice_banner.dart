import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/relative_time.dart';
import '../../../data/models/meta/app_config.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 홈 공지 배너: 탭 > 공지 상세 화면(#529), 닫기 > 읽음 처리(같은 공지 다시 안 띄움)
/// 머리글(작은 스피커 + "중요 공지 · 1일 전") 아래 제목 한 줄 (#756).
/// 긴 제목은 잘리지 않고 흐른다 (마퀴, #701). 동작 줄이기면 말줄임
class AppNoticeBanner extends StatelessWidget {
  const AppNoticeBanner({
    super.key,
    required this.notice,
    required this.onDismiss,
  });

  final AppNotice notice;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final elapsed = formatNotificationElapsed(notice.publishedAt);
    // 머리글 색만 봐도 중요·일반이 갈리게 중요는 빨강 계열, 일반은 강조색
    final kindColor = notice.isImportant ? colors.wrongText : colors.accentText;
    // 홈 첫 구간(card 면) 안에 놓여 카드색 대신 화면 배경색 바탕으로 구분한다
    return PassqlPressable(
      onTap: () => context.push(AppRoutes.noticeDetail(notice.noticeUuid)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          PassqlSpacing.md,
          PassqlSpacing.sm,
          0,
          PassqlSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(PassqlRadius.lg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        // 머리글 앞 작은 스피커 (타일 없이 글자 크기에 맞춤)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(right: PassqlSpacing.xxs),
                            child: Icon(
                              CupertinoIcons.speaker_2_fill,
                              size: PassqlIconSize.xs,
                              color: kindColor,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: notice.isImportant ? '중요 공지' : '공지',
                          style: PassqlTypography.captionSemibold.copyWith(
                            color: kindColor,
                          ),
                        ),
                        if (elapsed.isNotEmpty) TextSpan(text: ' · $elapsed'),
                      ],
                    ),
                    style: PassqlTypography.caption.copyWith(
                      color: colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: PassqlSpacing.hairlineGap),
                  PassqlMarqueeText(
                    notice.title,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                ],
              ),
            ),
            // 닫기는 오른쪽 위
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(PassqlSize.minTouchTarget),
              onPressed: onDismiss,
              child: Semantics(
                label: '공지 닫기',
                child: Icon(
                  CupertinoIcons.xmark,
                  size: PassqlIconSize.md,
                  color: colors.iconSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
