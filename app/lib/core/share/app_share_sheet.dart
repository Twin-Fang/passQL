import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

/// 시스템 공유 창 공통 지점 (share_plus 는 여기서만 import, #1075)
abstract final class AppShareSheet {
  // 공유 이미지 형식
  static const String _pngMimeType = 'image/png';

  /// PNG 이미지 + 글 공유. [originRect] 는 iPad 공유 창이 붙을 버튼 위치
  static Future<void> sharePngImage({
    required Uint8List pngBytes,
    required String fileName,
    required String text,
    Rect? originRect,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: [
          XFile.fromData(pngBytes, mimeType: _pngMimeType, name: fileName),
        ],
        fileNameOverrides: [fileName],
        sharePositionOrigin: originRect,
      ),
    );
  }
}
