import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// 소리 모드 채널 (MainActivity.kt 와 같은 이름)
const MethodChannel _ringerModeChannel = MethodChannel('passql/ringer_mode');

/// 소리 모드: normal, vibrate, silent (iOS 는 OS 가 제공하지 않아 null, 실패 > null)
Future<String?> ringerModeReader() async {
  if (!Platform.isAndroid) return null;
  try {
    return await _ringerModeChannel.invokeMethod<String>('getRingerMode');
  } catch (_) {
    return null;
  }
}
