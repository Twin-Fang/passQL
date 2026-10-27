import 'dart:typed_data';

import '../image/webp_image_compressor.dart';

/// 의견 보내기 이미지 한도 (서버 검증과 같은 값)
abstract final class FeedbackImageLimits {
  /// 글당 첨부 최대 장수
  static const int maxImageCount = 10;

  /// 긴 변 최대 픽셀
  static const int longSidePixels = 1920;

  /// 장당 최대 용량 (600KB)
  static const int maxBytes = 600 * 1024;

  /// 품질 시도 순서 (최대 3회: 80 > 65 > 50)
  static const List<int> qualityLadder = [80, 65, 50];
}

/// 의견 첨부 이미지 압축: 원본 > WebP (긴 변 1920px, 600KB 이하, 썸네일 없음)
/// 실제 압축·검증은 공통 [WebpImageCompressor] 에 위임
class FeedbackImageCompressor {
  FeedbackImageCompressor({WebpImageCompressor? webpCompressor})
    : _webpCompressor = webpCompressor ?? WebpImageCompressor();

  final WebpImageCompressor _webpCompressor;

  Future<CompressedWebpImage> compress(Uint8List sourceBytes) =>
      _webpCompressor.compressToLimit(
        sourceBytes,
        longSidePixels: FeedbackImageLimits.longSidePixels,
        maxBytes: FeedbackImageLimits.maxBytes,
        qualityLadder: FeedbackImageLimits.qualityLadder,
      );
}
