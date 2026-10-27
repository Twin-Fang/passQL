import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../core/error/app_exception.dart';
import '../../core/error/error_code.dart';

/// WebP 인코더: 원본 바이트 > WebP 바이트 (minWidth/minHeight 는 라이브러리 규칙상 목표 가로·세로)
typedef WebpEncoder =
    Future<Uint8List?> Function(
      Uint8List sourceBytes, {
      required int minWidth,
      required int minHeight,
      required int quality,
    });

/// 이미지 바이트 > 가로·세로 픽셀
typedef ImageDimensionReader =
    Future<({int width, int height})> Function(Uint8List imageBytes);

/// 압축을 마친 WebP 1장 (매직바이트·EXIF·크기 검증 완료)
class CompressedWebpImage {
  const CompressedWebpImage({
    required this.bytes,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final int width;
  final int height;
}

/// 폰 안에서 WebP 로 압축하는 공통 지점 (커뮤니티·의견 보내기 공용)
/// 품질을 낮춰 가며 한도 안에 들 때까지 시도 > 매직바이트·EXIF·크기 검증 > 실패는 한국어 AppException
class WebpImageCompressor {
  WebpImageCompressor({
    WebpEncoder encodeWebp = _encodeWebpWithPlugin,
    ImageDimensionReader readDimensions = _readDimensionsWithEngine,
  }) : _encodeWebp = encodeWebp,
       _readDimensions = readDimensions;

  final WebpEncoder _encodeWebp;
  final ImageDimensionReader _readDimensions;

  /// 원본 바이트 > 긴 변·용량 한도 안의 WebP (품질 사다리 순서로 시도)
  Future<CompressedWebpImage> compressToLimit(
    Uint8List sourceBytes, {
    required int longSidePixels,
    required int maxBytes,
    required List<int> qualityLadder,
  }) async {
    final source = await _readDimensions(sourceBytes);
    final targetScale = math.min(
      1.0,
      longSidePixels / math.max(source.width, source.height),
    );
    final targetWidth = math.max(1, (source.width * targetScale).floor());
    final targetHeight = math.max(1, (source.height * targetScale).floor());

    for (final quality in qualityLadder) {
      // 라이브러리가 회전된 사진에서 가로·세로를 바꿔 해석하면 한 번 뒤집어 재시도
      for (final isSwapped in const [false, true]) {
        final encoded = await _encodeWebp(
          sourceBytes,
          minWidth: isSwapped ? targetHeight : targetWidth,
          minHeight: isSwapped ? targetWidth : targetHeight,
          quality: quality,
        );
        if (encoded == null || !isWebpBytes(encoded)) {
          throw _failure('이미지를 변환하지 못했어요. 다른 사진을 선택해 주세요.');
        }
        if (hasExifChunk(encoded)) {
          throw _failure('사진의 위치 정보를 지우지 못했어요. 다른 사진을 선택해 주세요.');
        }
        final output = await _readDimensions(encoded);
        if (math.max(output.width, output.height) > longSidePixels) {
          if (isSwapped) {
            throw _failure('사진 크기를 줄이지 못했어요. 다른 사진을 선택해 주세요.');
          }
          continue;
        }
        if (encoded.length <= maxBytes) {
          return CompressedWebpImage(
            bytes: encoded,
            width: output.width,
            height: output.height,
          );
        }
        break;
      }
    }
    throw _failure('사진 용량이 너무 커서 줄이지 못했어요. 다른 사진을 선택해 주세요.');
  }

  static AppException _failure(String message) =>
      AppException(code: ErrorCode.validation, message: message);

  /// WebP 매직바이트 검사: "RIFF" + 4바이트 크기 + "WEBP"
  static bool isWebpBytes(Uint8List bytes) =>
      bytes.length >= 12 &&
      _matchesAscii(bytes, 0, 'RIFF') &&
      _matchesAscii(bytes, 8, 'WEBP');

  /// WebP 컨테이너에 EXIF 청크(위치·기기 정보)가 남았는지 검사
  static bool hasExifChunk(Uint8List bytes) {
    var offset =
        12; // RIFF 헤더 12바이트 다음부터 청크 나열: FourCC(4) + 크기(4, little endian) + 데이터(짝수 패딩)
    while (offset + 8 <= bytes.length) {
      if (_matchesAscii(bytes, offset, 'EXIF')) return true;
      final chunkSize = ByteData.sublistView(
        bytes,
        offset + 4,
        offset + 8,
      ).getUint32(0, Endian.little);
      offset += 8 + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }
    return false;
  }

  static bool _matchesAscii(Uint8List bytes, int offset, String text) {
    for (var index = 0; index < text.length; index++) {
      if (bytes[offset + index] != text.codeUnitAt(index)) return false;
    }
    return true;
  }
}

// 실제 인코더: flutter_image_compress (iOS: SDWebImageWebPCoder, Android: Bitmap WEBP), EXIF 는 keepExif=false 로 제거
Future<Uint8List?> _encodeWebpWithPlugin(
  Uint8List sourceBytes, {
  required int minWidth,
  required int minHeight,
  required int quality,
}) => FlutterImageCompress.compressWithList(
  sourceBytes,
  minWidth: minWidth,
  minHeight: minHeight,
  quality: quality,
  format: CompressFormat.webp,
  keepExif: false,
);

// 실제 크기 판독: 엔진 디코더의 헤더 정보만 읽음 (전체 디코딩 없음)
Future<({int width, int height})> _readDimensionsWithEngine(
  Uint8List imageBytes,
) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(imageBytes);
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final dimensions = (width: descriptor.width, height: descriptor.height);
    descriptor.dispose();
    return dimensions;
  } finally {
    buffer.dispose();
  }
}
