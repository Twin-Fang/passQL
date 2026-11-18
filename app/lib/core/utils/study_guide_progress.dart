/// passQL 학습 가이드 단계 진행 계산 (#1078, 순수): 회차 기록 > 단계 4개 상태 > 지금 할 단계
/// 단계 순서: 최신 기출(52회 이후) > 이전 기출 > 모의고사 > FINAL
/// 상시 단계(개념·오늘의 세트·잠금화면)와 전 과정(오답노트)은 진행 계산 없이 바로가기만
library;

/// 2024 개정 범위가 시작된 시험 회차 (52회부터 최신 출제 범위)
const int latestSyllabusFirstExamRound = 52;

/// 진행을 세는 단계 4개
enum StudyGuideStage { latestPastExams, olderPastExams, mockExams, finalCheck }

/// 단계 > 제목 ('1단계 최신 기출 복원', 로드맵 화면·홈 입구 행 공통 원본, #1158)
String toStudyGuideStageTitle(StudyGuideStage stage) =>
    '${stage.index + 1}단계 ${switch (stage) {
      StudyGuideStage.latestPastExams => '최신 기출 복원',
      StudyGuideStage.olderPastExams => '이전 기출로 넓히기',
      StudyGuideStage.mockExams => '모의고사',
      StudyGuideStage.finalCheck => '시험 직전 FINAL',
    }}';

/// 단계 상태 4개: 준비 중(열린 회차 없음), 시작 전, 진행 중, 완료
enum StudyGuideStageStatus { notReady, notStarted, inProgress, done }

/// 회차 종류 3개 (계산용, 앱 모델과 분리)
enum StudyGuideRoundKind { pastExam, mock, finalRound }

/// 회차 1개 기록: 종류, 실제 시험 회차(기출만), 실전 응시 또는 학습 모드 완료 여부
typedef StudyGuideRoundRecord = ({
  StudyGuideRoundKind kind,
  int? examRoundNumber,
  bool isTouched,
});

/// 단계 1개 진행: 상태, 손댄 회차 수, 전체 회차 수
typedef StudyGuideStageProgress = ({
  StudyGuideStage stage,
  StudyGuideStageStatus status,
  int touchedRoundCount,
  int totalRoundCount,
});

/// 회차 기록 > 단계 4개 진행 (단계 순서대로)
List<StudyGuideStageProgress> calculateStudyGuideProgress(
  List<StudyGuideRoundRecord> rounds,
) => [
  for (final stage in StudyGuideStage.values)
    _toStageProgress(stage, rounds.where((round) => _isRoundOf(stage, round))),
];

/// 지금 할 단계: 순서상 첫 미완료 단계 (준비 중 단계는 건너뜀, 모두 끝났으면 null)
StudyGuideStage? findCurrentStudyGuideStage(
  List<StudyGuideStageProgress> stageProgresses,
) {
  for (final progress in stageProgresses) {
    if (progress.status == StudyGuideStageStatus.notStarted ||
        progress.status == StudyGuideStageStatus.inProgress) {
      return progress.stage;
    }
  }
  return null;
}

bool _isRoundOf(StudyGuideStage stage, StudyGuideRoundRecord round) =>
    switch (stage) {
      StudyGuideStage.latestPastExams =>
        round.kind == StudyGuideRoundKind.pastExam &&
            (round.examRoundNumber ?? 0) >= latestSyllabusFirstExamRound,
      StudyGuideStage.olderPastExams =>
        round.kind == StudyGuideRoundKind.pastExam &&
            (round.examRoundNumber ?? 0) < latestSyllabusFirstExamRound,
      StudyGuideStage.mockExams => round.kind == StudyGuideRoundKind.mock,
      StudyGuideStage.finalCheck =>
        round.kind == StudyGuideRoundKind.finalRound,
    };

/// 단계 상태: 회차 없음 > 준비 중, 손댄 회차 0 > 시작 전, 전부 > 완료, 그 외 > 진행 중
StudyGuideStageProgress _toStageProgress(
  StudyGuideStage stage,
  Iterable<StudyGuideRoundRecord> stageRounds,
) {
  final totalRoundCount = stageRounds.length;
  final touchedRoundCount = stageRounds
      .where((round) => round.isTouched)
      .length;
  final status = totalRoundCount == 0
      ? StudyGuideStageStatus.notReady
      : touchedRoundCount == 0
      ? StudyGuideStageStatus.notStarted
      : touchedRoundCount >= totalRoundCount
      ? StudyGuideStageStatus.done
      : StudyGuideStageStatus.inProgress;
  return (
    stage: stage,
    status: status,
    touchedRoundCount: touchedRoundCount,
    totalRoundCount: totalRoundCount,
  );
}
