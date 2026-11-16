import 'package:flutter_test/flutter_test.dart';
import 'package:passql_app/core/utils/study_guide_progress.dart';

/// 학습 가이드 단계 진행 (#1078): 52회 경계, 상태 4개, 지금 할 단계
void main() {
  StudyGuideRoundRecord pastRound(
    int examRoundNumber, {
    bool isTouched = false,
  }) => (
    kind: StudyGuideRoundKind.pastExam,
    examRoundNumber: examRoundNumber,
    isTouched: isTouched,
  );

  test('52회 이후 기출을 하나 풀면 1단계 진행 중, 이전 기출·FINAL 없으면 준비 중', () {
    final progresses = calculateStudyGuideProgress([
      pastRound(52, isTouched: true),
      pastRound(62),
      (kind: StudyGuideRoundKind.mock, examRoundNumber: null, isTouched: false),
    ]);

    expect(progresses.map((progress) => progress.status), [
      StudyGuideStageStatus.inProgress,
      StudyGuideStageStatus.notReady,
      StudyGuideStageStatus.notStarted,
      StudyGuideStageStatus.notReady,
    ]);
    expect(progresses.first.touchedRoundCount, 1);
    expect(progresses.first.totalRoundCount, 2);
    expect(
      findCurrentStudyGuideStage(progresses),
      StudyGuideStage.latestPastExams,
    );
  });

  test('1단계를 다 풀면 준비 중 단계를 건너뛰고 모의고사가 지금 할 단계', () {
    final progresses = calculateStudyGuideProgress([
      pastRound(61, isTouched: true),
      (kind: StudyGuideRoundKind.mock, examRoundNumber: null, isTouched: false),
    ]);

    expect(progresses.first.status, StudyGuideStageStatus.done);
    expect(findCurrentStudyGuideStage(progresses), StudyGuideStage.mockExams);
  });
}
