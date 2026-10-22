import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/sources/api_providers.dart';

/// 랜덤 풀기 1회 문제 수 (서버 size 상한 10)
const randomPracticeQuestionCount = 10;

/// 랜덤 풀기 문제 목록 조회: GET /questions/random (안 푼 문제 우선, 하루 한도는 상세 열기에서 서버가 적용)
class RandomPracticeService {
  RandomPracticeService(this._ref);

  final Ref _ref;

  Future<List<String>> fetchQuestionUuids() async {
    final questions = await _ref
        .read(questionApiProvider)
        .getRandomQuestions(size: randomPracticeQuestionCount);
    return questions.map((question) => question.questionUuid).toList();
  }
}

final randomPracticeServiceProvider = Provider<RandomPracticeService>(
  RandomPracticeService.new,
);
