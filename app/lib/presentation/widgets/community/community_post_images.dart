import 'package:flutter/cupertino.dart';

import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import '../../providers/community_image_providers.dart';
import 'community_image_thumbnail.dart';
import 'community_image_viewer.dart';

/// 의견 타일의 첨부 썸네일 1~2장 가로 배치: 탭 > 확대 뷰어
class CommunityPostImages extends StatelessWidget {
  const CommunityPostImages({super.key, required this.images});

  final List<CommunityPostImage> images;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Padding(
      padding: const EdgeInsets.only(
        top: PassqlSpacing.xs,
        right: PassqlSpacing.sm,
      ),
      child: Row(
        children: [
          for (final (index, image) in images.indexed) ...[
            if (index > 0) const SizedBox(width: PassqlSpacing.xs),
            Semantics(
              button: true,
              label: '첨부 사진 ${index + 1} 크게 보기',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => showCommunityImageViewer(
                  context,
                  images: images,
                  initialIndex: index,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(PassqlRadius.md),
                  child: Container(
                    width: PassqlSize.communityImageThumbnail,
                    height: PassqlSize.communityImageThumbnail,
                    color: colors.fill,
                    child: CommunityAuthImage(
                      imageUuid: image.imageUuid,
                      size: CommunityImageSize.thumbnail,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
