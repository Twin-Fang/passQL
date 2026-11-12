/// 알림 권한 안내 문구 (시트·설정 안내 공통 원본, 서비스 알림만 안내하고 광고·마케팅 표현 금지)
abstract final class NotificationPermissionTexts {
  static const String sheetTitle = '시험 접수일, 놓치지 않게 알려 드릴까요?';
  static const String sheetDescription = '이런 알림만 보내요';

  /// 미리 보여 줄 알림 2개 (제목, 본문, 받은 때): 서버 원서접수 마감 D-1·신고 처리 결과 알림 문구 그대로 (#1041)
  static const List<({String title, String body, String receivedAt})>
  previewNotifications = [
    (title: 'SQLD 원서접수 마감 D-1', body: '내일 원서접수가 끝나요', receivedAt: '지금'),
    (
      title: '신고하신 문제를 처리했어요',
      body: '제보해 주신 내용을 확인하고 처리를 마쳤어요',
      receivedAt: '어제',
    ),
  ];

  /// 보내는 알림 종류 한 줄 요약
  static const String sentKindsSummary = '시험 일정 · 학습 알림 · 신고 처리 결과 · 점검 안내만 보내요';

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
