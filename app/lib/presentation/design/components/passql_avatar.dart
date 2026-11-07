import 'package:flutter/widgets.dart';

import '../passql_theme.dart';
import '../tokens/passql_tokens.dart';

/// 원형 프로필 사진 (#908): 이미지 주소 > 원형 자르기, 없음·불러오는 중·실패면 첫 글자 원
/// 디코딩은 표시 크기 x 화면 배율로 줄여 메모리 절약, 같은 주소는 앱 이미지 캐시 재사용
/// 장식 요소라 스크린리더에서 숨김 (옆 닉네임이 읽힘)
class PassqlAvatar extends StatelessWidget {
  const PassqlAvatar({
    super.key,
    required this.size,
    required this.fallbackName,
    this.imageUrl,
  });

  final double size;

  /// 첫 글자 원에 쓰는 이름 (비면 ?)
  final String fallbackName;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final initialCircle = _InitialCircle(size: size, name: fallbackName);
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return ExcludeSemantics(child: initialCircle);
    }
    final decodeSize = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ExcludeSemantics(
      child: ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: decodeSize,
          cacheHeight: decodeSize,
          // 계정이 바뀌어도 이전 사진이 잠깐 남지 않게 주소가 바뀌면 다시 그림
          gaplessPlayback: false,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
              wasSynchronouslyLoaded || frame != null ? child : initialCircle,
          errorBuilder: (context, error, stackTrace) => initialCircle,
        ),
      ),
    );
  }
}

/// 이름 첫 글자 원 (강조 옅은 바탕 + 강조 글자)
class _InitialCircle extends StatelessWidget {
  const _InitialCircle({required this.size, required this.name});

  final double size;
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    final initial = name.isEmpty ? '?' : name.characters.first;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accentTint,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: PassqlTypography.headline.copyWith(color: colors.accentText),
      ),
    );
  }
}
