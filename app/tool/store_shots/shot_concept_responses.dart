// 스토어 캡처 가짜 API의 개념 학습 응답 (#577): 단원 9개 + 대표 개념 3개 (실제 콘텐츠)
// 원본: shot_concept_data.dart (content/concepts/export_shot_concepts.py 로 생성)
// 운영 코드(lib/)에는 영향이 없다.
import 'dart:convert';

import 'package:dio/dio.dart';

import 'shot_concept_data.dart';

final Map<String, dynamic> _shotConceptData =
    jsonDecode(shotConceptDataJson) as Map<String, dynamic>;

final RegExp _answerPath = RegExp(
  r'/concepts/([^/]+)/check-questions/([^/]+)/answer$',
);
final RegExp _checkQuestionsPath = RegExp(
  r'/concepts/([^/]+)/check-questions$',
);
final RegExp _progressPath = RegExp(r'/concepts/([^/]+)/progress$');
final RegExp _topicConceptsPath = RegExp(r'/concepts/topics/([^/]+)$');
final RegExp _conceptDetailPath = RegExp(r'/concepts/([^/]+)$');

/// 개념 API 가짜 응답 (개념 경로가 아니면 null, 캡처 데이터에 없는 개념 상세는 빈 응답 > 404)
Object? conceptShotResponse(RequestOptions options) {
  final path = options.path;
  if (!path.contains('/concepts/')) return null;

  // 채점 (보낸 보기 > 정답·풀이·보기별 이유)
  final answerMatch = _answerPath.firstMatch(path);
  if (answerMatch != null) {
    return _answerOf(answerMatch.group(2)!, options.data);
  }
  final questionsMatch = _checkQuestionsPath.firstMatch(path);
  if (questionsMatch != null) {
    return (_shotConceptData['questionsByConcept']
            as Map<String, dynamic>)[questionsMatch.group(1)] ??
        <Object>[];
  }
  // 진행 저장은 응답 본문 없음
  if (_progressPath.hasMatch(path)) return <String, dynamic>{};
  if (path.endsWith('/concepts/topics')) {
    return {
      'isAvailable': true,
      'freeTopicCount': 2,
      'topics': _shotConceptData['topics'],
    };
  }
  final topicMatch = _topicConceptsPath.firstMatch(path);
  if (topicMatch != null) {
    return (_shotConceptData['conceptsByTopic']
        as Map<String, dynamic>)[topicMatch.group(1)];
  }
  final detailMatch = _conceptDetailPath.firstMatch(path);
  if (detailMatch != null) {
    return (_shotConceptData['detailByConcept']
        as Map<String, dynamic>)[detailMatch.group(1)];
  }
  return null;
}

/// 문제 1개 채점: 보낸 보기 키 <-> 정답 키
Map<String, dynamic> _answerOf(String questionUuid, Object? requestData) {
  final answerKey =
      (_shotConceptData['answerKeyByQuestion']
              as Map<String, dynamic>)[questionUuid]
          as Map<String, dynamic>;
  // 요청 본문: retrofit 은 요청 객체(toJson 보유)를 그대로 넘김 > JSON 왕복으로 Map 변환
  final request =
      jsonDecode(requestData is String ? requestData : jsonEncode(requestData))
          as Map<String, dynamic>;
  return {
    'isCorrect': request['choiceKey'] == answerKey['correctKey'],
    'correctKey': answerKey['correctKey'],
    'explanation': answerKey['explanation'],
    'rereadAnchor': answerKey['rereadAnchor'],
    'rationaleByChoiceKey': answerKey['rationaleByChoiceKey'],
    'checkCorrectCount': 0,
    'checkSolvedCount': 0,
  };
}
