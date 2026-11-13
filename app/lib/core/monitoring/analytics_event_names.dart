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
  static const String notificationInboxOpened = 'notification_inbox_opened';
  static const String notificationItemOpened = 'notification_item_opened';
  static const String notificationPermissionPrompt =
      'notification_permission_prompt';
  static const String storeReviewRequested = 'store_review_requested';

  // 구매·광고 흐름 (#971): 시트 열림 > 이용권 선택 > 결제 시작 > 결제 결과, 한도 화면 > 광고 결과
  static const String passSheetOpened = 'pass_sheet_opened';
  static const String passOptionSelected = 'pass_option_selected';
  static const String passPurchaseStarted = 'pass_purchase_started';
  static const String passPurchaseResult = 'pass_purchase_result';
  static const String dailyLimitSheetOpened = 'daily_limit_sheet_opened';
  static const String adBonusResult = 'ad_bonus_result';

  // 잠금화면 문제 퍼널 (#990): 소개 > 미리보기 > 권한 단계 > 켜짐 > 표시 > 풀이·닫기·소진
  static const String lockScreenIntroShown = 'lockscreen_intro_shown';
  static const String lockScreenPreviewAnswered = 'lockscreen_preview_answered';
  static const String lockScreenEnabled = 'lockscreen_enabled';
  static const String lockScreenPermissionStep = 'lockscreen_permission_step';
  static const String lockScreenQuestionShown = 'lockscreen_question_shown';
  static const String lockScreenAnswered = 'lockscreen_answered';
  static const String lockScreenDismissed = 'lockscreen_dismissed';
  static const String lockScreenExhaustedShown = 'lockscreen_exhausted_shown';
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

  /// 알림함 탭: general, notice
  static const String inboxTab = 'tab';

  /// 알림 종류: ADMIN_MESSAGE, REPORT_RESOLVED, DAILY_SET_REMINDER, NOTICE
  static const String notificationType = 'type';

  /// 권한 안내 결과: accepted, later, denied
  static const String promptResult = 'result';

  /// 평가 요청을 일으킨 학습: daily_set, mock_exam
  static const String reviewTrigger = 'trigger';

  /// 이용권 상품 ID: pro_pass_1m, pro_pass_3m
  static const String productId = 'product_id';

  /// 이용권 시트 종류: 1 연장(이미 프로), 0 새 구매
  static const String isExtending = 'is_extending';

  /// 이용권 시트 진입점: sql_execute (없으면 보내지 않음)
  static const String source = 'source';

  /// 결제 결과: success, pending, cancelled, failed, unavailable / 광고 결과: rewarded, dismissedWithoutReward, unavailable
  static const String outcome = 'outcome';

  /// 잠금화면 권한 단계: overlay, notification, battery, samsung_power
  static const String permissionStep = 'step';

  /// 권한 켜짐: 1 켜짐, 0 꺼짐
  static const String isGranted = 'granted';

  /// 회원 등급: free, pro
  static const String tier = 'tier';
}
