package com.passql.web.controller;

import com.passql.ai.dto.AiResult;
import com.passql.ai.dto.SimilarQuestion;
import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
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
  })
  @Operation(summary = "SQL 차이 해설")
  ResponseEntity<AiResult> diffExplain(
      @AuthMember LoginMember loginMember,
      @RequestBody Map<String, Object> body
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
