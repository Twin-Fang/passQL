import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/relative_time.dart';
import '../../../data/models/meta/app_config.dart';
import '../../../router/app_routes.dart';
import '../../design/design.dart';

/// 홈 공지 배너: 탭 > 공지 상세 화면(#529), 닫기 > 읽음 처리(같은 공지 다시 안 띄움)
/// 머리글(작은 스피커 + "중요 공지 · 1일 전") 아래 제목 한 줄 (#756).
/// 제목은 길이와 상관없이 흐른다 (마퀴, #701·#756). 동작 줄이기면 멈춘 말줄임
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
        // 닫기 버튼 누르는 영역(44)이 글자 묶음보다 커서, 위 정렬이면 남는 높이가 아래에만 붙는다 > 가운데로 위아래 여백을 같게
        child: Row(
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
                    isAlwaysScrolling: true,
                    style: PassqlTypography.subheadlineSemibold.copyWith(
                      color: colors.label,
                    ),
                  ),
                ],
              ),
            ),
            // 닫기
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
