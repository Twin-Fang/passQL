// 가답안·가채점 캡처용 가짜 응답 (#1075, 서버 배포 전 화면 확인)
// 홈 구간: /exam-schedules/sqld 의 63회(2026-11-14) > /exam-answers/SQLD/63 (수집 중)
// 화면: SHOT_ROUTE=/exam-answers/SQLD/63, 답안지는 제출 전(404) > 채점하면 아래 결과
// 운영 코드(lib/)에는 영향이 없고, 빌드 산출물에도 포함되지 않는다.
import 'dart:convert';

import 'package:dio/dio.dart';

// 문항 상태 연출: 갈림 3개, 미확정 1개, 확정 10개, 나머지 우세
const Set<int> _disputedQuestionNos = {7, 23, 41};
const Set<int> _undecidedQuestionNos = {48};
const Set<int> _confirmedQuestionNos = {1, 2, 3, 11, 12, 13, 14, 15, 16, 17};

// 문항별 출제 개념 (번호 순환)
const List<(String, String, String)> _concepts = [
  ('식별자 종류 구분 (본질·인조 식별자)', '식별자,엔터티', 'data_modeling'),
  ('정규화 단계별 함수 종속 제거', '정규화,함수 종속', 'data_modeling'),
  ('GROUP BY 와 HAVING 실행 순서', 'GROUP BY,HAVING', 'sql_group_aggregate'),
  ('OUTER JOIN 결과 행 수 계산', 'OUTER JOIN', 'sql_join'),
  ('ROW_NUMBER, RANK, DENSE_RANK 차이', '순위 함수,윈도우', 'sql_window'),
  ('상관 서브쿼리와 EXISTS', '서브쿼리,EXISTS', 'sql_subquery'),
  ('NVL, COALESCE 의 NULL 처리', 'NULL,단일행 함수', 'sql_function'),
  ('TRUNCATE, DELETE, DROP 비교', 'DDL,DML', 'sql_ddl_dml_tcl'),
];

int _answerOf(int questionNo) => (questionNo * 7) % 4 + 1;

Map<String, dynamic> _itemOf(int questionNo) {
  final concept = _concepts[questionNo % _concepts.length];
  final answer = _answerOf(questionNo);
  final status = _disputedQuestionNos.contains(questionNo)
      ? 'DISPUTED'
      : _undecidedQuestionNos.contains(questionNo)
      ? 'UNKNOWN'
      : _confirmedQuestionNos.contains(questionNo)
      ? 'CONFIRMED'
      : 'LEADING';
  // 득표: 갈림은 두 보기가 비슷, 미확정은 고르게, 나머지는 한 보기 우세
  final tally = List<int>.filled(4, 0);
  final voteCount = 412 - questionNo * 3;
  if (status == 'DISPUTED') {
    tally[answer - 1] = (voteCount * 0.46).round();
    tally[answer % 4] = (voteCount * 0.41).round();
  } else if (status == 'UNKNOWN') {
    for (var index = 0; index < 4; index++) {
      tally[index] = voteCount ~/ 4;
    }
  } else {
    tally[answer - 1] = (voteCount * (0.7 + (questionNo % 5) * 0.05)).round();
  }
  final remaining = voteCount - tally.fold<int>(0, (sum, count) => sum + count);
  tally[(answer + 1) % 4] += remaining;
  return {
    'questionNo': questionNo,
    'subjectNo': questionNo <= 10 ? 1 : 2,
    'conceptTitle': concept.$1,
    'conceptTags': concept.$2.split(','),
    'topicCode': concept.$3,
    'answer': status == 'UNKNOWN' ? null : answer,
    'answerStatus': status,
    'alternativeAnswers': questionNo == 41 ? [answer % 4 + 1] : <int>[],
    'tally': {for (var index = 0; index < 4; index++) '${index + 1}': tally[index]},
    'voteCount': voteCount,
    'agreementRate': status == 'UNKNOWN' ? 0.25 : tally[answer - 1] / voteCount,
    'note': status == 'DISPUTED' ? '보기 $answer번과 ${answer % 4 + 1}번 해석이 갈려요. 공식 발표를 기다려 주세요.' : null,
  };
}

Map<String, dynamic> _roundResponse() => {
  'certType': 'SQLD',
  'roundNumber': 63,
  'title': 'SQLD 제63회',
  'examDate': '2026-11-14',
  'status': 'COLLECTING',
  'notice': null,
  'gradingRule': {
    'totalQuestionCount': 50,
    'pointsPerQuestion': 2,
    'maxScore': 100,
    'passScore': 60,
    'subjectFailBelowPercent': 40,
    'subjects': [
      {'subjectNo': 1, 'subjectName': '데이터 모델링의 이해', 'firstQuestionNo': 1, 'lastQuestionNo': 10, 'maxScore': 20, 'failBelowScore': 8},
      {'subjectNo': 2, 'subjectName': 'SQL 기본과 활용', 'firstQuestionNo': 11, 'lastQuestionNo': 50, 'maxScore': 80, 'failBelowScore': 32},
    ],
  },
  'items': [for (var questionNo = 1; questionNo <= 50; questionNo++) _itemOf(questionNo)],
  'participantCount': 1284,
  'updatedAt': DateTime.now().toUtc().subtract(const Duration(minutes: 3)).toIso8601String(),
};

/// 제출한 답안 > 서버 채점 결과 모양 (가짜: 표시 정답 기준, 갈림 범위 포함)
Map<String, dynamic> _gradeOf(String answers) {
  var subject1 = 0;
  var subject2 = 0;
  var rangeMin = 0;
  var rangeMax = 0;
  final perQuestion = <Map<String, dynamic>>[];
  for (var questionNo = 1; questionNo <= 50; questionNo++) {
    final myAnswer = int.tryParse(answers[questionNo - 1]) ?? 0;
    final answer = _answerOf(questionNo);
    final isUnsettled =
        _disputedQuestionNos.contains(questionNo) || _undecidedQuestionNos.contains(questionNo);
    final isCorrect = myAnswer != 0 && myAnswer == answer;
    final points = isCorrect ? 2 : 0;
    if (questionNo <= 10) {
      subject1 += points;
    } else {
      subject2 += points;
    }
    rangeMin += isUnsettled ? 0 : points;
    rangeMax += isUnsettled ? (myAnswer == 0 ? 0 : 2) : points;
    perQuestion.add({
      'questionNo': questionNo,
      'myAnswer': myAnswer,
      'answer': _undecidedQuestionNos.contains(questionNo) ? null : answer,
      'isCorrect': isUnsettled && myAnswer != 0 ? null : isCorrect,
    });
  }
  final total = subject1 + subject2;
  bool isPassed(int score, int s1, int s2) => score >= 60 && s1 >= 8 && s2 >= 32;
  final passStatus = isPassed(rangeMin, subject1, subject2)
      ? 'PASS'
      : isPassed(rangeMax, subject1, subject2)
      ? 'BORDERLINE'
      : 'FAIL';
  return {
    'certType': 'SQLD',
    'roundNumber': 63,
    'answers': answers,
    'source': 'APP',
    'submittedAt': DateTime.now().toUtc().toIso8601String(),
    'result': {
      'subject1': {'score': subject1, 'max': 20, 'isFailCut': subject1 < 8},
      'subject2': {'score': subject2, 'max': 80, 'isFailCut': subject2 < 32},
      'totalScore': total,
      'scoreRange': {'min': rangeMin, 'max': rangeMax},
      'passStatus': passStatus,
      'percentile': 24,
      'perQuestion': perQuestion,
    },
  };
}

// 이번 실행에서 제출한 답안 (GET 답안지가 돌려줌)
String? _submittedAnswers;

/// 가답안 경로면 응답(없으면 null > 404), 아니면 null
Object? examAnswerShotResponse(RequestOptions options) {
  final path = options.path;
  if (path.endsWith('/exam-schedules/sqld')) {
    return {
      'year': 2026,
      'schedules': [
        {'examScheduleUuid': '44444444-0000-4000-8000-000000000001', 'certType': 'SQLD', 'round': 63, 'examDate': '2026-11-14', 'isSelected': true},
      ],
    };
  }
  if (!path.contains('/exam-answers/')) return null;
  if (options.method == 'POST' && path.endsWith('/sheets')) {
    final body = options.data is String ? jsonDecode(options.data as String) : options.data;
    _submittedAnswers = (body as Map)['answers'] as String;
    return _gradeOf(_submittedAnswers!);
  }
  if (path.contains('/sheets/')) {
    final answers = _submittedAnswers;
    return answers == null ? null : _gradeOf(answers);
  }
  if (path.endsWith('/exam-answers/SQLD/63')) return _roundResponse();
  return null;
}
