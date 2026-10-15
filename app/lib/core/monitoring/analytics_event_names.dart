/// 분석 이벤트 이름 (Firebase 규칙: 영문 소문자·숫자·밑줄 40자 이내, firebase_·google_·ga_ 접두사 금지)
abstract final class AnalyticsEventNames {
  /// 로그인 완료 (GA 권장 이벤트 이름)
  static const String login = 'login';
  static const String answerSubmitted = 'answer_submitted';
  static const String dailySetCompleted = 'daily_set_completed';
  static const String chapterCompleted = 'chapter_completed';
  static const String wrongNotesOpened = 'wrong_notes_opened';
  static const String feedbackSent = 'feedback_sent';
  static const String questionReported = 'question_reported';
  static const String aiExplanationRequested = 'ai_explanation_requested';
}

/// 분석 이벤트 파라미터 이름 (값은 문자열·숫자만, 이메일·닉네임·SQL 답안 원문 금지)
abstract final class AnalyticsParameterNames {
  /// 로그인 방법: google, apple (GA 권장 파라미터 이름)
  static const String method = 'method';

  /// 정답 여부: 1 정답, 0 오답 (Firebase 가 bool 을 받지 않음)
  static const String isCorrect = 'is_correct';
  static const String topicCode = 'topic_code';
  static const String topicName = 'topic_name';
  static const String correctCount = 'correct_count';
  static const String questionCount = 'question_count';

  /// AI 해설 종류: sql_error, wrong_answer
  static const String explanationType = 'explanation_type';
}
