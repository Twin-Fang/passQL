package com.passql.web.controller;

import com.passql.ai.dto.AiResult;
import com.passql.ai.dto.SimilarQuestion;
import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.question.dto.explanation.ChoiceExplanationResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Tag(name = "AI", description = "AI 해설 / 유사 문제 조회")
public interface AiControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.04.07", author = Author.SUHSAECHAN, issueNumber = 1, description = "SQL 에러 AI 해설 API 추가"),
      @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 22, description = "Header: X-User-UUID(String) → X-Member-UUID(UUID). Body 내 questionId(Long) → questionUuid(UUID)"),
      @ApiLog(date = "2026.04.19", author = Author.SUHSAECHAN, issueNumber = 120, description = "X-Member-UUID 헤더 → @AuthMember JWT 인증 전환"),
  })
  @Operation(summary = "SQL 에러 해설")
  ResponseEntity<AiResult> explainError(
      @AuthMember LoginMember loginMember,
      @RequestBody Map<String, Object> body
  );

  @ApiLogs({
      @ApiLog(date = "2026.04.07", author = Author.SUHSAECHAN, issueNumber = 1, description = "SQL 차이 AI 해설 API 추가"),
      @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 22, description = "Header: X-User-UUID(String) → X-Member-UUID(UUID)"),
      @ApiLog(date = "2026.04.19", author = Author.SUHSAECHAN, issueNumber = 120, description = "X-Member-UUID 헤더 → @AuthMember JWT 인증 전환"),
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 521, description = "text 를 세트 구조화 해설의 마크다운으로 교체(판정·정답 근거·핵심 개념·헷갈리는 지점·보기별 판단·시험 팁). 출시 앱 호환용 동기 경로, 새 화면은 GET /api/ai/choice-explanation 사용"),
  })
  @Operation(
      summary = "선택지 해설 (동기, 출시 앱 호환)",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 본문
          - **`questionUuid`**: 문제
          - **`selectedChoiceKey`**: 고른 보기 (생략 시 마지막 제출의 보기)

          ## 반환값 (AiResult)
          - text: 구조화 해설을 그린 마크다운 (굵게·인라인 코드·'- ' 목록만 사용)
          - 구조화 해설이 아직 없으면 옛 보기별 해설 글을 바로 주고 백그라운드 생성, 둘 다 없으면 생성 완료를 최대 25초 기다림
          - 생성 실패·시간 초과 시 503 AI_UNAVAILABLE
          """
  )
  ResponseEntity<AiResult> diffExplain(
      @AuthMember LoginMember loginMember,
      @RequestBody Map<String, Object> body
  );

  @ApiLogs({
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 521, description = "선택지 구조화 해설 조회 API 추가 (기다리지 않고 READY/GENERATING/FAILED 상태 반환, 생성 중이면 재조회)"),
  })
  @Operation(
      summary = "선택지 구조화 해설 조회",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 파라미터
          - **`questionUuid`**: 문제 (필수)
          - **`choiceSetUuid`**: 제출한 선택지 세트 (선택, 생략 시 이 문제 마지막 제출의 세트). 이 세트로 제출한 기록이 없으면 400
          - **`selectedChoiceKey`**: 고른 보기 (선택, 생략 시 제출한 보기)

          ## 반환값 (ChoiceExplanationResponse) — 응답은 항상 즉시
          - **READY**: explanation(구조화) + text(마크다운). 고정 세트·옛 해설이면 explanation 은 null, text 만
          - **GENERATING**: 생성 중. retryAfterMilliseconds 뒤 같은 요청으로 다시 조회. text 는 옛 해설이 있으면 임시 표시용
          - **FAILED**: 재시도 상한(3회) 도달. text 는 옛 해설이 있으면 표시용, 없으면 null

          ## explanation (ChoiceExplanation) 화면 순서
          verdict(판정 한 줄, 정답 여부는 서버 정답 데이터 기준) > correctReason > keyConcepts[] > confusingPoints[] > choiceAnalyses[] > examTip
          - 문장 안 `코드` 는 인라인 SQL 조각 (코드 블록 없음)

          ## 동작
          - 해설은 선택지 세트 저장 직후 미리 생성되어 대부분 바로 READY
          - 프롬프트 버전이 바뀐 낡은 해설도 READY 로 즉시 주고 백그라운드에서 다시 만든다
          - 다음 문제로 넘어가도 choiceSetUuid 로 앞 문제 해설을 계속 받을 수 있다
          """
  )
  ResponseEntity<ChoiceExplanationResponse> getChoiceExplanation(
      @AuthMember LoginMember loginMember,
      @RequestParam UUID questionUuid,
      @RequestParam(required = false) UUID choiceSetUuid,
      @RequestParam(required = false) String selectedChoiceKey
  );

  @ApiLogs({
      @ApiLog(date = "2026.04.07", author = Author.SUHSAECHAN, issueNumber = 1, description = "유사 문제 조회 API 추가"),
      @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 22, description = "PathVariable: Long id → UUID questionUuid. 응답 DTO SimilarQuestion{questionUuid, stem, topicName, score}"),
      @ApiLog(date = "2026.10.08", author = Author.SUHSAECHAN, issueNumber = 442, description = "미구현(TODO, 항상 500)이던 검색을 구현 — 기준 문제 벡터로 Qdrant 검색, 자기 자신 제외. 실패 시 빈 목록"),
  })
  @Operation(
      summary = "유사 문제 조회",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 파라미터
          - **`questionUuid`**: 기준 문제
          - **`k`**: 개수 (1~5로 보정, 기본 5)

          ## 반환값 (List<SimilarQuestion>)
          - questionUuid, stem(앞 100자), topicName, score(코사인 유사도) — 유사도 높은 순
          - 기준 문제 자신과 비활성 문제는 빠진다
          - 기준 문제가 아직 색인되지 않았거나 AI 서버·Qdrant 가 실패하면 빈 배열 (500 아님)
          """
  )
  ResponseEntity<List<SimilarQuestion>> getSimilar(
      @PathVariable UUID questionUuid,
      @RequestParam(defaultValue = "5") int k
  );
}
