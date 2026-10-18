import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/design.dart';
import '../../providers/community_image_providers.dart';

/// 인증 헤더가 필요한 커뮤니티 이미지 1장: 받는 동안 로딩, 실패하면 탭해서 다시 시도
/// 받기는 회원별 메모리 캐시를 거침 (같은 이미지는 1번만 요청)
class CommunityAuthImage extends ConsumerStatefulWidget {
  const CommunityAuthImage({
    super.key,
    required this.imageUuid,
    required this.size,
    this.fit = BoxFit.cover,
  });

  final String imageUuid;
  final CommunityImageSize size;
  final BoxFit fit;

  @override
  ConsumerState<CommunityAuthImage> createState() => _CommunityAuthImageState();
}

class _CommunityAuthImageState extends ConsumerState<CommunityAuthImage> {
  Future<Uint8List>? _bytesFuture;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  @override
  void didUpdateWidget(CommunityAuthImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUuid != widget.imageUuid ||
        oldWidget.size != widget.size) {
      _startLoading();
    }
  }

  void _startLoading() {
    _bytesFuture = ref
        .read(communityImageCacheProvider)
        ?.load(widget.imageUuid, widget.size);
  }

  @override
  Widget build(BuildContext context) {
    // 회원이 바뀌면 캐시가 새로 만들어지므로 다시 받음
    ref.listen(communityImageCacheProvider, (_, _) {
      setState(_startLoading);
    });
    final bytesFuture = _bytesFuture;
    if (bytesFuture == null) {
      return const Center(child: PassqlLoadingIndicator());
    }
    final colors = context.passqlColors;
    return FutureBuilder<Uint8List>(
      future: bytesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Semantics(
            button: true,
            label: '이미지를 불러오지 못했어요. 눌러서 다시 시도',
            excludeSemantics: true,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => setState(_startLoading),
              child: Icon(
                CupertinoIcons.arrow_clockwise,
                size: PassqlIconSize.lg,
                color: colors.tertiaryLabel,
              ),
            ),
          );
        }
        final bytes = snapshot.data;
        if (bytes == null) {
          return const Center(child: PassqlLoadingIndicator());
        }
        return Image.memory(
          bytes,
          fit: widget.fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => Icon(
            CupertinoIcons.photo,
            size: PassqlIconSize.lg,
            color: colors.tertiaryLabel,
          ),
        );
      },
    );
  }
}
