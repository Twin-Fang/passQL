import 'dart:typed_data';

import '../image/webp_image_compressor.dart';

/// 커뮤니티 이미지 한도 (서버 검증과 같은 값)
abstract final class CommunityImageLimits {
  /// 본체 긴 변 최대 픽셀
  static const int imageLongSidePixels = 1600;

  /// 본체 최대 용량 (500KB)
  static const int imageMaxBytes = 500 * 1024;

  /// 썸네일 긴 변 최대 픽셀
  static const int thumbnailLongSidePixels = 320;

  /// 썸네일 최대 용량 (60KB)
  static const int thumbnailMaxBytes = 60 * 1024;

  /// 글당 첨부 최대 장수
  static const int maxImageCountPerPost = 2;

  /// 본체 품질 시도 순서 (최대 3회: 80 > 65 > 50)
  static const List<int> imageQualityLadder = [80, 65, 50];

  /// 썸네일 품질 시도 순서
  static const List<int> thumbnailQualityLadder = [70, 55, 40];
}

/// 압축을 마친 이미지 1장: 본체 + 썸네일 (둘 다 WebP 검증 완료)
class CompressedCommunityImage {
  const CompressedCommunityImage({
    required this.imageBytes,
    required this.thumbnailBytes,
    required this.width,
    required this.height,
  });

  final Uint8List imageBytes;
  final Uint8List thumbnailBytes;
  final int width;
  final int height;
}

/// 첨부 대기 이미지: 압축 결과 + 업로드가 끝났으면 서버 imageUuid (재시도 때 다시 올리지 않음)
class CommunityImageDraft {
  CommunityImageDraft(this.compressed);

  final CompressedCommunityImage compressed;
  String? uploadedImageUuid;

  bool get isUploaded => uploadedImageUuid != null;
}

/// 첨부 대기 이미지를 순서대로 1장씩 올리고 imageUuid 목록을 돌려줌
/// 이미 올라간 장은 건너뜀, 실패하면 그 자리에서 던져 이후 장은 올리지 않음 (올라간 장은 draft 에 기록)
Future<List<String>> uploadCommunityImageDrafts(
  List<CommunityImageDraft> drafts,
  Future<String> Function(CompressedCommunityImage compressed) uploadImage,
) async {
  for (final draft in drafts) {
    if (draft.isUploaded) continue;
    draft.uploadedImageUuid = await uploadImage(draft.compressed);
  }
  return [for (final draft in drafts) draft.uploadedImageUuid!];
}

/// 폰 안에서 WebP 로 압축: 본체(긴 변 1600px, 500KB 이하) + 썸네일(긴 변 320px, 60KB 이하)
/// 실제 압축·검증은 공통 [WebpImageCompressor] 에 위임
class CommunityImageCompressor {
  CommunityImageCompressor({WebpImageCompressor? webpCompressor})
    : _webpCompressor = webpCompressor ?? WebpImageCompressor();

  final WebpImageCompressor _webpCompressor;

  /// 원본 바이트 > 본체 + 썸네일 (썸네일은 압축된 본체에서 만들어 EXIF 회전 영향 없음)
  Future<CompressedCommunityImage> compress(Uint8List sourceBytes) async {
    final image = await _webpCompressor.compressToLimit(
      sourceBytes,
      longSidePixels: CommunityImageLimits.imageLongSidePixels,
      maxBytes: CommunityImageLimits.imageMaxBytes,
      qualityLadder: CommunityImageLimits.imageQualityLadder,
    );
    final thumbnail = await _webpCompressor.compressToLimit(
      image.bytes,
      longSidePixels: CommunityImageLimits.thumbnailLongSidePixels,
      maxBytes: CommunityImageLimits.thumbnailMaxBytes,
      qualityLadder: CommunityImageLimits.thumbnailQualityLadder,
    );
    return CompressedCommunityImage(
      imageBytes: image.bytes,
      thumbnailBytes: thumbnail.bytes,
      width: image.width,
      height: image.height,
    );
  }
}
