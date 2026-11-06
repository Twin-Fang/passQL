// 가짜 미리보기: 서버의 잠긴 내용이 아니라 모양만 그럴듯한 고정 예시 (통신을 가로채도 얻을 것이 없게, #578)
// 문구 원본: 앱 locked_preview_samples.dart

interface LockedSampleSection {
  readonly title: string;
  readonly body: string;
}

/** 제목 + 한 줄 본문 묶음 카드 (모든 가짜 미리보기 공통 모양) */
function LockedSampleCard({ sections }: { readonly sections: readonly LockedSampleSection[] }) {
  return (
    <div className="bg-surface-card border border-border rounded-2xl p-4 space-y-3">
      {sections.map((section) => (
        <div key={section.title}>
          <p className="text-xs font-semibold text-text-secondary">{section.title}</p>
          <p className="text-sm text-text-primary mt-1">{section.body}</p>
        </div>
      ))}
    </div>
  );
}

// 선택지 해설 묶음: 정답 근거, 핵심 개념, 헷갈리는 지점, 시험 팁
const EXPLANATION_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "정답 근거", body: "GROUP BY 절에 없는 컬럼은 집계 함수 없이 SELECT 에 쓸 수 없어요." },
  { title: "핵심 개념", body: "WHERE 는 그룹으로 묶기 전에, HAVING 은 묶은 뒤에 조건을 걸어요." },
  { title: "헷갈리는 지점", body: "COUNT(*) 는 NULL 도 세고, COUNT(컬럼) 은 NULL 을 빼고 세요." },
  { title: "시험 팁", body: "보기마다 실행 순서를 한 줄씩 적어 보면 함정이 보여요." },
];

// 통계 약점 분석: 토픽별 정답률, AI 코멘트
const STATS_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "약한 토픽", body: "서브쿼리 42% · 윈도우 함수 55% · 조인 61%" },
  { title: "토픽별 정답률", body: "레이더 차트로 7일 정답률 비교" },
  { title: "강한 토픽", body: "집계 함수 88% · 정렬 84%" },
];

// AI 분석 코멘트: 예상 점수, 약한 영역, 다음 공부 (#860, #862)
const AI_ANALYSIS_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "예상 점수 64점 · 합격선 근처", body: "1과목 예상 6/10 · 2과목 예상 26/40" },
  { title: "약한 영역", body: "조인과 서브쿼리 정답률이 낮아요. 이 두 영역을 가장 많이 틀렸어요." },
  { title: "다음 공부", body: "OUTER JOIN 결과 행 수 문제부터 다시 풀어 보세요." },
];

// 출제 경향: 과목 비중, 늘어난 유형, 예상
const EXAM_TREND_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "과목별 비중", body: "1과목 20% · 2과목 80%" },
  { title: "늘어난 유형", body: "결과 비교형 보기 · 윈도우 함수 순위" },
  { title: "이번 회차 예상", body: "조인과 서브쿼리 결과 추적이 이어질 가능성이 커요." },
];

// 오답 노트: 최근 틀린 문제 목록
const WRONG_NOTES_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "서브쿼리", body: "급여가 부서 평균보다 높은 사원을 찾는 SQL 은?" },
  { title: "윈도우 함수", body: "RANK 와 DENSE_RANK 결과가 다른 행은?" },
  { title: "조인", body: "OUTER JOIN 결과 행 수로 알맞은 것은?" },
];

// 모의고사 과목 분석: 과목 점수·과락, 약한 토픽 (#866)
const MOCK_EXAM_SUBJECT_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "1과목 데이터 모델링의 이해", body: "14 / 20점 · 정답 7개" },
  { title: "2과목 SQL 기본 및 활용", body: "52 / 80점 · 정답 26개" },
  { title: "약한 토픽", body: "계층형·PIVOT 33% · 윈도우 함수 40%" },
];

// 모의고사 문항 해설: 내 답·정답·보기 근거
const MOCK_EXAM_REVIEW_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "17번 · 내 답 2 · 정답 4", body: "LEFT OUTER JOIN 은 왼쪽 행을 모두 남겨 결과가 5행이에요." },
  { title: "보기 3 근거", body: "ON 절 조건과 WHERE 절 조건은 외부 조인에서 결과가 달라요." },
  { title: "다음에 할 일", body: "조인 결과 행 수 문제를 10개 더 풀어 보세요." },
];

// 모의고사 점수 추이: 회차별 점수
const MOCK_EXAM_SCORE_TREND_SAMPLE_SECTIONS: readonly LockedSampleSection[] = [
  { title: "제1회", body: "58점 · 불합격" },
  { title: "제2회", body: "66점 · 합격" },
  { title: "제3회", body: "72점 · 합격" },
];

export function ExplanationLockedSample() {
  return <LockedSampleCard sections={EXPLANATION_SAMPLE_SECTIONS} />;
}

export function StatsLockedSample() {
  return <LockedSampleCard sections={STATS_SAMPLE_SECTIONS} />;
}

export function AiAnalysisLockedSample() {
  return <LockedSampleCard sections={AI_ANALYSIS_SAMPLE_SECTIONS} />;
}

export function ExamTrendLockedSample() {
  return <LockedSampleCard sections={EXAM_TREND_SAMPLE_SECTIONS} />;
}

export function WrongNotesLockedSample() {
  return <LockedSampleCard sections={WRONG_NOTES_SAMPLE_SECTIONS} />;
}

export function MockExamSubjectLockedSample() {
  return <LockedSampleCard sections={MOCK_EXAM_SUBJECT_SAMPLE_SECTIONS} />;
}

export function MockExamReviewLockedSample() {
  return <LockedSampleCard sections={MOCK_EXAM_REVIEW_SAMPLE_SECTIONS} />;
}

export function MockExamScoreTrendLockedSample() {
  return <LockedSampleCard sections={MOCK_EXAM_SCORE_TREND_SAMPLE_SECTIONS} />;
}
