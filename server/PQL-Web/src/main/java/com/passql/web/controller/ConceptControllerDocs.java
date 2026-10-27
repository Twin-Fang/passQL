package com.passql.web.controller;

import com.passql.application.concept.dto.ConceptCheckAnswerRequest;
import com.passql.application.concept.dto.ConceptCheckAnswerResponse;
import com.passql.application.concept.dto.ConceptCheckQuestionResponse;
import com.passql.application.concept.dto.ConceptDetailResponse;
import com.passql.application.concept.dto.ConceptListResponse;
import com.passql.application.concept.dto.ConceptProgressRequest;
import com.passql.application.concept.dto.ConceptTopicListResponse;
import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.UUID;

@Tag(name = "Concept", description = "단원별 개념 학습 (읽기·확인 문제·진행)")
public interface ConceptControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 577, description = "개념 단원 목록 API 추가"),
  })
  @Operation(summary = "개념 단원 목록",
      description = """
          ## 인증(JWT): **필요**
          - isAvailable=false 면 개념 기능 숨김 (공개 전이고 미리보기 회원이 아님), topics 는 빈 목록
          - orderIndex 0부터, freeTopicCount 미만은 무료. 그 외는 결제 켜짐 + 무료 회원이면 isLocked=true
          - 개념이 없는 단원은 내려주지 않음""")
  ResponseEntity<ConceptTopicListResponse> getTopics(@AuthMember LoginMember loginMember);

  @ApiLogs({
      @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 577, description = "단원의 개념 목록 API 추가"),
  })
  @Operation(summary = "단원의 개념 목록",
      description = "잠긴 단원도 제목·상태·정답 수는 내려줌 (블러 목록용). status: NOT_STARTED / READ / SOLVED")
  ResponseEntity<ConceptListResponse> getConcepts(@AuthMember LoginMember loginMember, UUID topicUuid);

  @ApiLogs({
      @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 577, description = "개념 상세 API 추가"),
  })
  @Operation(summary = "개념 상세",
      description = """
          - coreMd: 핵심만 (마크다운), detailSections: 자세히 문단 (anchor 는 확인 문제 '다시 읽기' 이동 지점)
          - previousConceptUuid / nextConceptUuid: 같은 단원 안 이웃 (없으면 null)
          - 잠긴 단원: 403 PRO_REQUIRED, 공개 전 초안·없는 개념: 404 CONCEPT_NOT_FOUND""")
  ResponseEntity<ConceptDetailResponse> getConceptDetail(@AuthMember LoginMember loginMember, UUID conceptUuid);

  @ApiLogs({
      @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 577, description = "개념 확인 문제 목록 API 추가"),
  })
  @Operation(summary = "개념 확인 문제 목록",
      description = "개념당 5개, 보기 순서대로. 정답·풀이는 채점 응답에서만 내려줌. 잠금·초안 규칙은 개념 상세와 같음")
  ResponseEntity<List<ConceptCheckQuestionResponse>> getCheckQuestions(@AuthMember LoginMember loginMember, UUID conceptUuid);

  @ApiLogs({
      @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 577, description = "개념 진행 저장 API 추가"),
  })
  @Operation(summary = "개념 진행 저장",
      description = "null 칸은 기존값 유지. isRead 는 true 로만 바뀜 (읽음 해제 없음). lastMode: READ/SOLVE, lastDepth: CORE/DETAIL. 204")
  ResponseEntity<Void> saveProgress(@AuthMember LoginMember loginMember, UUID conceptUuid, ConceptProgressRequest request);

  @ApiLogs({
      @ApiLog(date = "2026.10.27", author = Author.SUHSAECHAN, issueNumber = 577, description = "개념 확인 문제 채점 API 추가"),
  })
  @Operation(summary = "개념 확인 문제 채점",
      description = """
          - 정답 여부·정답 키·풀이·다시 읽기 앵커·보기별 근거를 돌려줌
          - checkCorrectCount / checkSolvedCount: 문제별 마지막 답 기준 누적 (다시 풀어 틀리면 정답 수가 줄어듦)
          - 제출 기록·통계·오답 노트·하루 무료 한도에는 반영하지 않음""")
  ResponseEntity<ConceptCheckAnswerResponse> answerCheckQuestion(
      @AuthMember LoginMember loginMember, UUID conceptUuid, UUID questionUuid, ConceptCheckAnswerRequest request);
}
