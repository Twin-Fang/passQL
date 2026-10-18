import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../data/models/community/community_models.dart';
import '../../design/design.dart';
import '../../providers/community_image_providers.dart';
import 'community_image_thumbnail.dart';

/// 첨부 사진 확대 뷰어: 전체 화면, 좌우로 넘기기, 핀치 줌, 닫기 버튼
Future<void> showCommunityImageViewer(
  BuildContext context, {
  required List<CommunityPostImage> images,
  required int initialIndex,
}) => Navigator.of(context, rootNavigator: true).push(
  CupertinoPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) =>
        _CommunityImageViewerPage(images: images, initialIndex: initialIndex),
  ),
);

class _CommunityImageViewerPage extends StatefulWidget {
  const _CommunityImageViewerPage({
    required this.images,
    required this.initialIndex,
  });

  final List<CommunityPostImage> images;
  final int initialIndex;

  @override
  State<_CommunityImageViewerPage> createState() =>
      _CommunityImageViewerPageState();
}

class _CommunityImageViewerPageState extends State<_CommunityImageViewerPage> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late int _currentIndex = widget.initialIndex;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    // 검정 바탕이라 상태바 아이콘은 항상 밝게
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: CupertinoPageScaffold(
        backgroundColor: colors.imageViewerBackground,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (_, index) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: CommunityAuthImage(
                    imageUuid: widget.images[index].imageUuid,
                    size: CommunityImageSize.full,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(PassqlSpacing.xs),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: '닫기',
                      excludeSemantics: true,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(
                          PassqlSize.minTouchTarget,
                          PassqlSize.minTouchTarget,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: PassqlIconSize.lg,
                          color: colors.onImageViewer,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (widget.images.length > 1)
                      Text(
                        '${_currentIndex + 1}/${widget.images.length}',
                        style: PassqlTypography.subheadline.copyWith(
                          color: colors.onImageViewer,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
