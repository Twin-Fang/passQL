/// 알림 권한 안내 문구 (시트·설정 안내 공통 원본, 서비스 알림만 안내하고 광고·마케팅 표현 금지)
abstract final class NotificationPermissionTexts {
  static const String sheetTitle = '중요한 소식을 알려 드릴까요?';

  /// 받게 되는 소식 3가지
  static const List<String> receivedNewsLines = [
    '서비스 공지·점검 안내',
    '신고한 문제의 처리 결과',
    '시험 일정·학습 알림',
  ];

  static const String optionalNotice = '알림을 꺼도 모든 기능을 쓸 수 있어요';
  static const String acceptLabel = '알림 받기';
  static const String laterLabel = '나중에';

  // 거부된 상태에서 설정 토글을 켰을 때의 기기 설정 안내
  static const String openSettingsTitle = '알림이 꺼져 있어요';
  static const String openSettingsMessage = '기기 설정에서 passQL 알림을 켜 주세요.';
  static const String openSettingsLabel = '설정 열기';

  // 기기 설정 화면을 앱에서 열 수 없는 플랫폼(Android)의 안내
  static const String manualSettingsGuide = '기기 설정 > 앱 > passQL > 알림에서 켜 주세요';
}
