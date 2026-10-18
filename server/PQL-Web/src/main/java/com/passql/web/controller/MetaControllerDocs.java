package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.meta.constant.LegalType;
import com.passql.meta.dto.AppConfigResponse;
import com.passql.meta.dto.AppLinksResponse;
import com.passql.meta.dto.AppNoticePageResponse;
import com.passql.meta.dto.AppNoticeResponse;
import com.passql.meta.dto.LegalResponse;
import com.passql.meta.dto.TopicTree;
import com.passql.meta.dto.ConceptTagResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.UUID;

@Tag(name = "Meta", description = "주제 트리 / 개념 태그 조회")
public interface MetaControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.04.07", author = Author.SUHSAECHAN, issueNumber = 1, description = "주제 트리 조회 API 추가"),
      @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 22, description = "Topic/Subtopic PK 를 UUID 로 재작성. TopicTree 내부 식별자(topicUuid/subtopicUuid) UUID 기반으로 변경"),
  })
  @Operation(
      summary = "주제 트리 조회",
      description = """
          ## 인증(JWT): **불필요**

          ## 요청 파라미터
          - 없음

          ## 반환값 (List<TopicTree>)
          - topic > subtopic 계층 구조의 전체 트리
          - 각 노드 식별자는 UUID (topicUuid / subtopicUuid)
          """
  )
  ResponseEntity<List<TopicTree>> getTopics();

  @ApiLogs({
      @ApiLog(date = "2026.04.07", author = Author.SUHSAECHAN, issueNumber = 1, description = "활성 태그 조회 API 추가"),
      @ApiLog(date = "2026.04.08", author = Author.SUHSAECHAN, issueNumber = 22, description = "ConceptTag PK 를 UUID(conceptTagUuid) 로 재작성. tagKey 는 unique 컬럼으로 보존"),
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 517, description = "엔티티 대신 응답 DTO 반환 — 감사 필드(createdAt·updatedAt·createdBy·updatedBy) 제외, 스키마 이름 ConceptTag 유지"),
  })
  @Operation(
      summary = "활성 태그 조회",
      description = """
          ## 인증(JWT): **불필요**

          ## 요청 파라미터
          - 없음

          ## 반환값 (List<ConceptTag>)
          - 활성화된 개념 태그 전체 목록
          - 식별자는 conceptTagUuid (UUID), 비즈니스 키 tagKey 동시 노출
          - 필드: conceptTagUuid, tagKey, labelKo, category, description, isActive, sortOrder
          """
  )
  ResponseEntity<List<ConceptTagResponse>> getTags();

  @ApiLogs({
      @ApiLog(date = "2026.04.24", author = Author.SUHSAECHAN, issueNumber = 283, description = "공개 약관 조회 API 추가 — TERMS_OF_SERVICE / PRIVACY_POLICY"),
  })
  @Operation(
      summary = "공개 약관 조회",
      description = """
          ## 인증(JWT): **불필요**

          ## 경로 변수
          - **`type`**: TERMS_OF_SERVICE | PRIVACY_POLICY

          ## 반환값 (LegalResponse)
          - title: 약관 제목
          - content: 약관 본문 (마크다운)
          - status: PUBLISHED

          ## 에러
          - 404: 해당 type의 PUBLISHED 약관이 없는 경우
          """
  )
  ResponseEntity<LegalResponse> getLegal(@PathVariable LegalType type);

  @ApiLogs({
      @ApiLog(date = "2026.10.08", author = Author.SUHSAECHAN, issueNumber = 433, description = "스토어 다운로드 링크 조회 API 추가 — 웹 앱 출시 안내용"),
  })
  @Operation(
      summary = "스토어 다운로드 링크 조회",
      description = """
          ## 인증(JWT): **불필요**

          ## 요청 파라미터
          - 없음

          ## 반환값 (AppLinksResponse)
          - androidUrl: Google Play 링크 (없으면 null)
          - iosUrl: App Store 링크 (없으면 null)
          - 관리자 설정 store.android_url / store.ios_url 값. 비었거나 https 가 아니면 null
          """
  )
  ResponseEntity<AppLinksResponse> getAppLinks();

  @ApiLogs({
      @ApiLog(date = "2026.10.15", author = Author.SUHSAECHAN, issueNumber = 464, description = "앱 시작 설정 조회 API 추가 — 최소/권장 버전, 점검, 공지"),
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 529, description = "공지에 게시 시각 publishedAt 추가"),
  })
  @Operation(
      summary = "앱 시작 설정 조회",
      description = """
          ## 인증(JWT): **불필요**
          앱 시작 시 1회 호출. 점검 중에도 503 없이 응답한다.

          ## 요청 파라미터
          - 없음

          ## 반환값 (AppConfigResponse)
          - ios / android (AppPlatformVersionResponse)
            - minimumVersion: 최소 지원 버전 (x.y.z). 앱 버전이 이보다 낮으면 업데이트 전까지 사용 차단
            - recommendedVersion: 권장 버전 (x.y.z). 앱 버전이 이보다 낮으면 닫을 수 있는 업데이트 안내
            - storeUrl: 스토어 링크 (없으면 null)
            - 기본값 0.0.0 = 차단·안내 없음
          - maintenance (AppMaintenanceResponse)
            - isUnderMaintenance: 점검 중 여부. true 이면 meta·auth 외 /api 요청은 503 SERVICE_UNDER_MAINTENANCE
            - message: 점검 문구 (비면 앱 기본 문구)
          - notices (List<AppNoticeResponse>)
            - 지금 노출할 공지. 중요 공지 먼저, 그다음 최근 등록 순
            - noticeUuid, title, body, startsAt, endsAt(KST, null 가능), isActive, isImportant
            - publishedAt: 게시 시각 (노출 시작, 없으면 등록 시각, KST)
          """
  )
  ResponseEntity<AppConfigResponse> getAppConfig();

  @ApiLogs({
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 529, description = "공지 목록 조회 API 추가 — 지난 공지 포함, 페이지"),
  })
  @Operation(
      summary = "공지 목록 조회",
      description = """
          ## 인증(JWT): **불필요**
          점검 중에도 응답한다.

          ## 요청 파라미터
          - **`page`** (선택): 0부터 시작하는 페이지 번호, 기본 0
          - **`size`** (선택): 페이지 크기, 기본 20, 최대 50

          ## 반환값 (AppNoticePageResponse)
          - notices (List<AppNoticeResponse>): 활성 + 노출 시작이 지난 공지 (노출 기간이 끝난 지난 공지 포함)
            - 정렬: 노출 중인 중요 공지 먼저 > 게시 시각 최신 순
            - body 는 마크다운 일부(굵게 **, 목록 - , 링크 [이름](https://...))
          - page: 현재 페이지 번호
          - hasNextPage: 다음 페이지 유무
          """
  )
  ResponseEntity<AppNoticePageResponse> getNotices(@RequestParam(required = false) Integer page,
      @RequestParam(required = false) Integer size);

  @ApiLogs({
      @ApiLog(date = "2026.10.18", author = Author.SUHSAECHAN, issueNumber = 529, description = "공지 상세 조회 API 추가"),
  })
  @Operation(
      summary = "공지 상세 조회",
      description = """
          ## 인증(JWT): **불필요**

          ## 경로 변수
          - **`noticeUuid`**: 공지 UUID

          ## 반환값 (AppNoticeResponse)
          - noticeUuid, title, body(마크다운 일부), startsAt, endsAt, isActive, isImportant, publishedAt

          ## 에러
          - 404 APP_NOTICE_NOT_FOUND: 없음·비활성·노출 시작 전 공지
          """
  )
  ResponseEntity<AppNoticeResponse> getNotice(@PathVariable UUID noticeUuid);
}
