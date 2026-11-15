import '../mock_exam/mock_exam_enums.dart';

/// 오답 노트 정렬 2종 (서버 WrongQuestionSort, #1081)
enum WrongQuestionSort {
  recent('RECENT', '최근 틀린 순'),
  mostWrong('MOST_WRONG', '많이 틀린 순');

  const WrongQuestionSort(this.serverValue, this.label);

  /// 요청 쿼리 값
  final String serverValue;

  /// 화면 이름
  final String label;
}

/// 과목 > 요청 쿼리 값 (서버 MockExamSubject, unknown 은 필터 없음 null)
String? subjectQueryValueOf(MockExamSubject? subject) => switch (subject) {
  MockExamSubject.subjectOne => 'SUBJECT_ONE',
  MockExamSubject.subjectTwo => 'SUBJECT_TWO',
  _ => null,
};

/// 요청 쿼리 값 > 과목 (없거나 모르는 값 > null 전체)
MockExamSubject? subjectFromQueryValue(String? queryValue) =>
    switch (queryValue) {
      'SUBJECT_ONE' => MockExamSubject.subjectOne,
      'SUBJECT_TWO' => MockExamSubject.subjectTwo,
      _ => null,
    };
