/// 알림 권한 안내 시트 결과 3종 (분석 이벤트 값 = [name])
enum NotificationPermissionPromptResult {
  /// "알림 받기" > 시스템 권한 허용
  accepted,

  /// "나중에" 또는 시트 닫기
  later,

  /// "알림 받기" > 시스템 권한 거부
  denied,
}
