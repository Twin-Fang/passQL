import 'package:flutter/cupertino.dart';

import '../../../data/feedback/feedback_image_compressor.dart';
import '../../../data/image/webp_image_compressor.dart';
import '../../design/design.dart';

/// 의견 첨부 사진 1장의 상태: 압축 중이면 [image] 가 null
class FeedbackImageDraft {
  const FeedbackImageDraft({required this.id, this.image});

  /// 목록 안에서 장을 구분하는 번호 (압축이 끝나는 순서와 무관)
  final int id;
  final CompressedWebpImage? image;

  bool get isCompressing => image == null;
}

/// 사진 첨부 줄: 맨 앞 "+ 사진 n/10" 칸 + 장별 썸네일(압축 중 로딩, 우상단 X 로 제거)
class FeedbackImageStrip extends StatelessWidget {
  const FeedbackImageStrip({
    super.key,
    required this.drafts,
    required this.onAddPressed,
    required this.onRemovePressed,
  });

  final List<FeedbackImageDraft> drafts;

  /// null 이면 추가 불가 (최대 장수 가득, 전송 중)
  final VoidCallback? onAddPressed;
  final ValueChanged<int> onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PassqlSize.communityImageDraftPreview,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: drafts.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: PassqlSpacing.xs),
        itemBuilder: (_, index) => index == 0
            ? _AddTile(count: drafts.length, onPressed: onAddPressed)
            : _DraftTile(
                draft: drafts[index - 1],
                onRemovePressed: () => onRemovePressed(drafts[index - 1].id),
              ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.count, required this.onPressed});

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    const maxCount = FeedbackImageLimits.maxImageCount;
    return PassqlPressable(
      onTap: onPressed,
      semanticLabel: '사진 추가, $count/$maxCount',
      child: Container(
        width: PassqlSize.communityImageDraftPreview,
        height: PassqlSize.communityImageDraftPreview,
        decoration: BoxDecoration(
          color: colors.fill,
          borderRadius: BorderRadius.circular(PassqlRadius.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.photo,
              size: PassqlIconSize.lg,
              color: onPressed == null ? colors.tertiaryLabel : colors.accent,
            ),
            Text(
              '+ 사진 $count/$maxCount',
              style: PassqlTypography.caption.copyWith(
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.draft, required this.onRemovePressed});

  final FeedbackImageDraft draft;
  final VoidCallback onRemovePressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final image = draft.image;
    return SizedBox.square(
      dimension: PassqlSize.communityImageDraftPreview,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(PassqlRadius.md),
            child: image == null
                ? ColoredBox(
                    color: colors.fill,
                    child: const Center(child: PassqlLoadingIndicator()),
                  )
                : Image.memory(
                    image.bytes,
                    fit: BoxFit.cover,
                    // 원본 크기로 디코딩하지 않도록 칸 크기 기준으로 줄임
                    cacheWidth:
                        (PassqlSize.communityImageDraftPreview *
                                MediaQuery.devicePixelRatioOf(context))
                            .round(),
                  ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: PassqlSemanticButton(
              label: '사진 제거',
              onTap: onRemovePressed,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemovePressed,
                // 보이는 원은 24, 누르는 영역은 모서리 44x44
                child: SizedBox.square(
                  dimension: PassqlSize.minTouchTarget,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: PassqlSize.communityImageRemoveBadge,
                      height: PassqlSize.communityImageRemoveBadge,
                      margin: const EdgeInsets.all(PassqlSpacing.xxs),
                      decoration: BoxDecoration(
                        color: colors.cardElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.xmark,
                        size: PassqlIconSize.sm,
                        color: colors.label,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
