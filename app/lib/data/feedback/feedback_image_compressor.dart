import 'dart:typed_data';

import '../image/webp_image_compressor.dart';

/// 의견 보내기 이미지 한도 (서버 검증과 같은 값)
abstract final class FeedbackImageLimits {
  /// 글당 첨부 최대 장수
  static const int maxImageCount = 5;

  /// 긴 변 최대 픽셀
  static const int longSidePixels = 1280;

  /// 장당 최대 용량 (300KB)
  static const int maxBytes = 300 * 1024;

  /// 품질 시도 순서 (최대 3회: 70 > 55 > 40, 화소보다 압축을 세게)
  static const List<int> qualityLadder = [70, 55, 40];
}

/// 의견 첨부 이미지 압축: 원본 > WebP (긴 변 1280px, 300KB 이하, 썸네일 없음)
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
