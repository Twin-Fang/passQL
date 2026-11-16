import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mock_exam/mock_exam_study_progress_store.dart';
import '../../core/utils/study_guide_progress.dart';
import '../../data/models/mock_exam/mock_exam_enums.dart';
import '../../data/models/mock_exam/mock_exam_round_list.dart';
import 'mock_exam_providers.dart';

/// 학습 가이드 단계 진행 (#1078): 회차 목록(실전 응시) + 기기 학습 모드 완료 회차 > 단계 4개
final studyGuideProgressProvider =
    FutureProvider.autoDispose<List<StudyGuideStageProgress>>((ref) async {
      final roundList = await ref.watch(mockExamRoundsProvider.future);
      final studiedRoundUuids =
          await MockExamStudyProgressStore.readCompletedRoundUuids();
      return calculateStudyGuideProgress([
        for (final round in roundList.rounds)
          if (_toStudyGuideRoundKind(round.roundType) case final kind?)
            (
              kind: kind,
              examRoundNumber: round.examRoundNumber,
              isTouched:
                  _hasSubmittedAttempt(round) ||
                  studiedRoundUuids.contains(round.roundUuid),
            ),
      ]);
    });

/// 앱 회차 종류 > 계산용 종류 (모르는 종류는 빠짐)
StudyGuideRoundKind? _toStudyGuideRoundKind(MockExamRoundType roundType) =>
    switch (roundType) {
      MockExamRoundType.pastExam => StudyGuideRoundKind.pastExam,
      MockExamRoundType.mock => StudyGuideRoundKind.mock,
      MockExamRoundType.finalRound => StudyGuideRoundKind.finalRound,
      MockExamRoundType.unknown => null,
    };

bool _hasSubmittedAttempt(MockExamRoundSummary round) =>
    round.submittedAttemptCount > 0;
