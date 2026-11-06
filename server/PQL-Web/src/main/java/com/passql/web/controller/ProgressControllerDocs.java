package com.passql.web.controller;

import com.passql.ai.dto.AiCommentResponse;
import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.submission.dto.HeatmapResponse;
import com.passql.submission.dto.ProgressResponse;
import com.passql.submission.dto.TopicAnalysisResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDate;
import java.util.UUID;

@Tag(name = "Progress", description = "학습 진도 조회")
public interface ProgressControllerDocs {

    @ApiLogs({
        @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 4, description = "진도 요약 조회 API"),
        @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 22, description = "Submission PK 를 UUID 로 재작성. memberUuid(UUID) 기준 집계. 응답 DTO: ProgressResponse{solvedCount, correctRate(0.0~1.0 둘째자리 반올림), streakDays(하루 그레이스)}"),
        @ApiLog(date = "2026.04.10", author = Author.SUHSAECHAN, issueNumber = 52, description = "합격 준비도(readiness) 블록 응답에 추가 — Accuracy × Coverage × Recency 3요소 곱셈 + D-day 기반 toneKey. 기존 3필드 보존."),
        @ApiLog(date = "2026.04.19", author = Author.SUHSAECHAN, issueNumber = 120, description = "memberUuid 쿼리 파라미터 → @AuthMember JWT 인증 전환"),
    })
    @Operation(
        summary = "진도 요약 조회",
        description = """
            ## 인증(JWT): **필요**

            ## 반환값 (ProgressResponse)
            - solvedCount: 푼 문제 수 (distinct questionUuid 기준)
            - correctRate: 정답률 (0.0~1.0, 마지막 시도 기준, 소수 둘째자리 반올림)
            - streakDays: 연속 학습 일수 (하루 그레이스 — 오늘 미제출이어도 어제까지 연속이면 유지)
            - 제출 이력 0건이면 solvedCount=0, correctRate=0.0, streakDays=0

            ## readiness (합격 준비도 블록)
            - score: Accuracy × Coverage × Recency (0.0~1.0, 소수 둘째자리)
            - accuracy: 최근 50시도의 정답률
            - coverage: 최근 14일 내 푼 활성 토픽 수 / 활성 토픽 전체 수
            - recency: 마지막 학습일 기반 감쇠 계수 (0.70~1.00)
            - lastStudiedAt: 마지막 시도 시각 (ISO-8601), 미시도시 null
            - recentAttemptCount: 최근 50 윈도우 실제 시도 수
            - coveredTopicCount / activeTopicCount: 커버리지 분자/분모
            - daysUntilExam: 선택된 시험 일정 기준 D-day (없으면 null)
            - toneKey: 카피 톤 키 (NO_EXAM / ONBOARDING / POST_EXAM / TODAY / SPRINT / PUSH / STEADY / EARLY)
            """
    )
    ResponseEntity<ProgressResponse> getProgress(
        @AuthMember LoginMember loginMember
    );

    @ApiLogs({
        @ApiLog(date = "2026.04.10", author = Author.SUHSAECHAN, issueNumber = 42, description = "날짜별 학습 기록 히트맵 API 추가 — DATE(submitted_at) 기준 GROUP BY 집계, sparse array 반환"),
        @ApiLog(date = "2026.04.19", author = Author.SUHSAECHAN, issueNumber = 120, description = "memberUuid 쿼리 파라미터 → @AuthMember JWT 인증 전환"),
    })
    @Operation(
        summary = "날짜별 학습 히트맵 조회",
        description = """
            ## 인증(JWT): **필요**

            ## 요청 파라미터
            - from (LocalDate, optional): 조회 시작일 (기본: 30일 전)
            - to (LocalDate, optional): 조회 종료일 (기본: 오늘)

            ## 반환값 (HeatmapResponse)
            - entries: 날짜별 학습 기록 배열 (풀이 없는 날짜는 제외)
              - date: 날짜 (LocalDate)
              - solvedCount: 해당 날짜 풀이 수
              - correctCount: 해당 날짜 정답 수
            """
    )
    ResponseEntity<HeatmapResponse> getHeatmap(
        @AuthMember LoginMember loginMember,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
        @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to
    );

    @ApiLogs({
        @ApiLog(date = "2026.04.10", author = Author.SUHSAECHAN, issueNumber = 71, description = "토픽별 정답률/문제수 분석 API 추가"),
        @ApiLog(date = "2026.04.19", author = Author.SUHSAECHAN, issueNumber = 120, description = "memberUuid 쿼리 파라미터 → @AuthMember JWT 인증 전환"),
    })
    @Operation(
        summary = "토픽별 분석 조회",
        description = """
            ## 인증(JWT): **필요**

            ## 반환값 (TopicAnalysisResponse)
            - topicStats: 토픽별 집계 목록
              - topicUuid: 토픽 식별자
              - displayName: 토픽 표시명
              - totalQuestionCount: (폐기 예정) solvedCount 와 같은 값, 구버전 앱 호환용. 전체 문제 수는 노출하지 않음
              - correctRate: 최근 7일 정답률 (0.0~1.0, 문제별 최근 시도 기준, 레이더차트용)
              - solvedCount: 최근 7일 내 푼 문제 수
            - Submission 없는 토픽도 correctRate=0.0, solvedCount=0으로 포함
            """
    )
    ResponseEntity<TopicAnalysisResponse> getTopicAnalysis(
        @AuthMember LoginMember loginMember
    );

    @ApiLogs({
        @ApiLog(date = "2026.04.10", author = Author.SUHSAECHAN, issueNumber = 71, description = "AI 영역 분석 코멘트 API 추가 (Redis 캐시 24h TTL, Submission 저장 시 evict)"),
        @ApiLog(date = "2026.04.12", author = Author.SUHSAECHAN, issueNumber = 176, description = "sessionUuid 파라미터 추가. 캐시 키 세션 단위 변경(ai-comment:{memberUuid}:{sessionUuid}, TTL 2h). 프롬프트 DB 이관(ai_comment 키). 이번 세션 결과 + 누적 통계 통합 피드백."),
        @ApiLog(date = "2026.04.19", author = Author.SUHSAECHAN, issueNumber = 120, description = "memberUuid 쿼리 파라미터 → @AuthMember JWT 인증 전환"),
        @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 699, description = "통계 코멘트(sessionUuid 없음) 무료 개방: 무료 하루 1회·프로 최근 풀이 10문제마다 갱신 (캐시 키 ai-comment:{memberUuid}:stats:{날짜}:{구간}, TTL 24h). 세션 코멘트는 프로 전용 유지 (무료 403 PRO_REQUIRED)"),
        @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 860, description = "통계·세션 코멘트 모두 프로 전용 (무료 403 PRO_REQUIRED), 세션 코멘트는 본인 세션 제출만 집계"),
        @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 861, description = "통계 코멘트에 구조화 분석(analysis) 추가: 서버 판정 집중 토픽 2개·근거·주간 추세·강점·바로 풀기 버튼, LLM 은 토픽별 한 문장(ai_analysis_stats). comment 는 구버전 앱용 평문 유지, 세션 코멘트 analysis=null"),
        @ApiLog(date = "2026.11.07", author = Author.SUHSAECHAN, issueNumber = 862, description = "analysis 에 periodLabel·forecast(과목별 예상 점수·과락 판정)·forecastHint·repeatedWrong·readiness(데이터 부족)·nextGoal, findings[].conceptTopicUuid, 버튼 RANDOM_PRACTICE·PRACTICE_LATEST_TREND 추가. 세션 코멘트는 서버 문장 + 놓친 문제 LLM 한 문장(ai_analysis_session), LLM 실패해도 200. 통계 캐시 키 구간 접두 guide-"),
    })
    @Operation(
        summary = "AI 영역 분석 코멘트 조회",
        description = """
            ## 인증(JWT): **필요**

            ## 요청 파라미터
            - sessionUuid (UUID, optional): 퀴즈 세션 식별자 (없으면 통계 화면 코멘트, 본인 세션 제출만 집계)

            ## 등급
            - 프로 전용 (결제 켜짐 무료 회원 403 PRO_REQUIRED, 결제 꺼짐이면 모두 허용)

            ## 반환값 (AiCommentResponse)
            - comment: 한국어 코멘트. 세션: 서버 문장 + AI 한 문장 / 통계: analysis 를 이어 붙인 평문 (구버전 앱 호환, 마크다운 없음)
            - generatedAt: 코멘트 생성(캐시 저장) 시각
            - analysis (통계 화면만, 세션은 null): 서버 판정 구조화 분석
              - headline: 한 줄 요약 (시험 30일 이내면 "D-N · " 접두)
              - findings[] (최대 2): topicUuid, topicName(짧은 이름), kind(WEAK 약점·SHAKY 불안정·UNTRIED 판단 이름), solvedCount, correctRatePercent, evidence, insight(LLM 한 문장, 실패·근거 부족이면 null)
              - trend: 이번 주 vs 지난주 정답률 (두 주 모두 풀이 있을 때만, 아니면 null)
              - strength: 10문제 이상·85% 이상 중 최고 토픽 (없으면 null)
              - actions[] (최대 2): type(PRACTICE_TOPIC 토픽 풀기·REVIEW_WRONG 오답 다시 풀기·RANDOM_PRACTICE 랜덤 풀기·PRACTICE_LATEST_TREND 최신 경향 풀기), topicUuid·topicName(PRACTICE_TOPIC 만), count(표시용), label. 모르는 type 은 화면이 숨김
              - findings[].conceptTopicUuid: 이 회원이 열 수 있는 개념 학습 단원(같은 토픽)일 때만, 아니면 null
              - periodLabel: 판정 기간 표기 ("최근 90일 기준")
              - forecast (근거 부족이면 null): SQLD 1과목 10·2과목 40문항 기준 예상 맞힐 수, expectedScore(100점), isSubjectOneFailRisk·isSubjectTwoFailRisk(40% 미만), verdict(SUBJECT_FAIL_RISK·PASS_LIKELY 70+·BORDERLINE 54~68·BELOW_PASS), verdictLabel, summary, detail
                - 1과목 = 토픽 data_modeling 정답률, 2과목 = 나머지 토픽 같은 비중 평균(토픽별 풀이 적으면 2과목 전체 정답률 쪽으로 5문제분 당김), 최근 90일
                - 1과목 5문제·2과목 20문제 미만이면 forecast=null, forecastHint="1과목 2문제 더 풀면 예상 점수를 알려 드려요"
              - repeatedWrong (2문제 미만이면 null): 최근 90일 같은 문제 2번 이상 틀린 문제 수, 그중 마지막 시도도 오답인 수, text
              - readiness (데이터 부족만): 5문제 이상 푼 토픽이 하나도 없을 때. message, topicName(가장 많이 푼 토픽), solvedCount, targetCount(5). 이때 findings·forecast 없음
              - nextGoal (모두 안정권만): 안 푼 토픽 시작 또는 최신 경향 권유
              - 판정 기준·문구는 서버 규칙 고정, LLM 실패해도 analysis 는 응답 (insight 만 null)
            - 세션 코멘트 comment: 서버 문장(점수 > 놓친 토픽 > 그 토픽 최근 90일 판정) + 오답 있으면 LLM 한 문장(ai_analysis_session), LLM 실패면 서버 문장만

            ## 캐싱
            - Redis key: ai-comment:{memberUuid}:{sessionUuid}, TTL 2시간
            - 통계: ai-comment:{memberUuid}:stats:{날짜}:guide-{최근 7일 풀이 수/10}, TTL 24시간 (LLM 실패 응답은 캐시하지 않음, 세션도 같음)
            - 같은 세션 재진입 시 동일 텍스트 반환 (불필요한 AI 호출 방지)
            - 새 세션 시작 시 새 sessionUuid로 자동 새 AI 호출
            - AI 호출 latency를 고려해 프론트엔드에서 비동기 로딩 권장
            """
    )
    ResponseEntity<AiCommentResponse> getAiComment(
        @AuthMember LoginMember loginMember,
        @RequestParam(required = false) UUID sessionUuid
    );
}
