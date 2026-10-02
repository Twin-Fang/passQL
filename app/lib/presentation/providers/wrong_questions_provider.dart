import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_providers.dart';
import '../../data/models/progress/wrong_questions_response.dart';

/// 오답 노트에 한 번에 보여줄 최대 개수.
const wrongNotePageSize = 20;

/// 오답 노트 Provider. 화면을 벗어나면 해제되어 돌아올 때 최신 오답을 다시 받는다.
///
/// 실패는 그대로 노출해 화면이 재시도 UI 를 보여주게 한다(선택적 섹션이 아니라
/// 이 섹션의 본 기능이므로 조용히 비우지 않는다).
final wrongQuestionsProvider =
    FutureProvider.autoDispose<WrongQuestionsResponse>(
      (ref) => ref
          .read(progressApiProvider)
          .getWrongQuestions(size: wrongNotePageSize),
    );
