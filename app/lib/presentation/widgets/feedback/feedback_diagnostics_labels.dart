// 진단 JSON 키 > 표시 이름 (표시 전용, 서버로 보내는 키는 그대로)
const Map<String, String> diagnosticLabelByKey = {
  'appVersion': '앱 버전',
  'buildNumber': '빌드 번호',
  'installerStore': '설치 경로',
  'memberUuid': '회원 ID',
  'authProvider': '로그인 방식',
  'isPro': 'Pro 여부',
  'themeMode': '테마',
  'choiceMode': '풀이 모드',
  'currentRoute': '직전 화면',
  'pushPermission': '알림 권한',
  'hasPushToken': '푸시 토큰 등록',
  'platform': '플랫폼',
  'osVersion': 'OS 버전',
  'deviceModel': '기기 모델',
  'manufacturer': '제조사',
  'isPhysicalDevice': '실기기 여부',
  'locale': '언어',
  'timeZone': '시간대',
  'screenWidthPixels': '화면 너비(px)',
  'screenHeightPixels': '화면 높이(px)',
  'devicePixelRatio': '픽셀 배율',
  'textScaleFactor': '글자 배율',
  'platformBrightness': '시스템 화면 모드',
  'isBatterySaveMode': '절전 모드',
  'batteryLevelPercent': '배터리(%)',
  'batteryState': '충전 상태',
  'networkType': '네트워크',
  'ringerMode': '소리 모드',
  'collectedAt': '수집 시각',
};

// 예/아니요로 읽히는 질문형 boolean 키 (그 외 boolean 은 켜짐/꺼짐)
const Set<String> _yesNoQuestionKeys = {'isPro', 'hasPushToken', 'isPhysicalDevice'};

/// 키 > 표시 이름 (없는 키는 원문)
String diagnosticLabelOf(String key) => diagnosticLabelByKey[key] ?? key;

/// 값 > 표시 문자열 (null '-', boolean 예/아니요 또는 켜짐/꺼짐)
String diagnosticValueLabelOf(String key, Object? value) {
  if (value == null) return '-';
  if (value is bool) {
    if (_yesNoQuestionKeys.contains(key)) return value ? '예' : '아니요';
    return value ? '켜짐' : '꺼짐';
  }
  return value.toString();
}
