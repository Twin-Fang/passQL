/// SQLD 시험 고정 안내 (#991, 시험 일정 화면 시험 정보 묶음 원본)
/// 공식 안내(데이터자격검정)가 바뀌면 여기만 고친다
abstract final class SqldExamFacts {
  // 시험 시간 (분)·문항 수: 서버 모의고사 규칙(MockExamRuleResponse)과 같은 값
  static const int examDurationMinutes = 90;
  static const int questionCount = 50;
  // 응시료 (원)
  static const int examFeeWon = 50000;
  static const String eligibility = '제한 없음';
  // 공식 접수 안내 (입실 시간·준비물)
  static const String officialGuideUrl =
      'https://www.dataq.or.kr/www/accept/guide.do';
  // 서버가 공식 일정 주소를 주지 않을 때 접수 버튼이 여는 곳
  static const String fallbackOfficialScheduleUrl =
      'https://www.dataq.or.kr/www/accept/schedule.do';
}
