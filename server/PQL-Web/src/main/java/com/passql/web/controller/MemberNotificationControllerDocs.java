package com.passql.web.controller;

import com.passql.common.dto.Author;
import com.passql.member.auth.presentation.annotation.AuthMember;
import com.passql.member.auth.presentation.security.LoginMember;
import com.passql.member.dto.NotificationPageResponse;
import com.passql.member.dto.UnreadNotificationCountResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import kr.suhsaechan.suhapilog.annotation.ApiLog;
import kr.suhsaechan.suhapilog.annotation.ApiLogs;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@Tag(name = "Notification", description = "알림함 목록 / 안 읽은 개수 / 읽음 처리")
public interface MemberNotificationControllerDocs {

  @ApiLogs({
      @ApiLog(date = "2026.10.16", author = Author.SUHSAECHAN, issueNumber = 491, description = "알림함 목록 조회 API 추가 (알림·공지 탭, 커서 페이지)"),
  })
  @Operation(
      summary = "알림함 목록 조회",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 파라미터
          - **`category`**: GENERAL(알림, 기본값) / NOTICE(공지)
          - **`cursor`**: 이전 응답의 nextCursor (처음이면 비움, GENERAL 만 사용)
          - **`size`**: 페이지 크기 (기본 20, 최대 50, GENERAL 만 사용)

          ## 반환값 (NotificationPageResponse)
          - **`items`**: id, category, type, title, body, linkTarget, linkQuestionUuid, isRead, createdAt, isImportant
          - **`nextCursor`**: 다음 페이지 커서 (마지막이면 null)

          ## 설명
          - GENERAL: 회원별 알림 최신순 커서 페이지. 관리자가 회수한 알림은 제외한다.
          - NOTICE: 지금 노출 중인 공지 전체(중요 먼저). id 는 공지 UUID, isRead 는 회원의 읽음 기록, nextCursor 는 항상 null.
          - 공지 항목의 linkTarget·linkQuestionUuid 는 null.
          """
  )
  NotificationPageResponse getNotifications(@AuthMember LoginMember loginMember,
                                            @RequestParam(required = false) String category,
                                            @RequestParam(required = false) String cursor,
                                            @RequestParam(required = false) Integer size);

  @ApiLogs({
      @ApiLog(date = "2026.10.16", author = Author.SUHSAECHAN, issueNumber = 491, description = "안 읽은 알림 개수 조회 API 추가"),
  })
  @Operation(
      summary = "안 읽은 알림 개수 조회",
      description = """
          ## 인증(JWT): **필요**

          ## 반환값 (UnreadNotificationCountResponse)
          - **`general`**: 알림 탭 안 읽은 수
          - **`notice`**: 공지 탭 안 읽은 수 (노출 중 공지 중 안 읽은 것)
          - **`total`**: general + notice (종 아이콘·앱 아이콘 숫자)

          ## 설명
          - 회원별 30초 캐시. 알림 생성·읽음·회수 때 해당 회원 캐시를 비운다.
          - 앱은 화면마다 부르지 않고 시작·복귀·푸시 수신·알림함 진입·읽음 처리 후에만 호출한다.
          """
  )
  UnreadNotificationCountResponse getUnreadCount(@AuthMember LoginMember loginMember);

  @ApiLogs({
      @ApiLog(date = "2026.10.16", author = Author.SUHSAECHAN, issueNumber = 491, description = "알림·공지 1건 읽음 처리 API 추가"),
  })
  @Operation(
      summary = "알림·공지 1건 읽음 처리",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 파라미터
          - **`id`**: GENERAL 은 알림 UUID, NOTICE 는 공지 UUID (app_notice_uuid)
          - **`category`**: GENERAL(기본값) / NOTICE

          ## 설명
          - 성공 시 204(본문 없음). 이미 읽었거나 없는 id 도 204 (멱등).
          - 본인 알림만 바뀐다.
          """
  )
  void markRead(@AuthMember LoginMember loginMember, @PathVariable String id,
                @RequestParam(required = false) String category);

  @ApiLogs({
      @ApiLog(date = "2026.10.16", author = Author.SUHSAECHAN, issueNumber = 491, description = "알림·공지 모두 읽음 처리 API 추가"),
  })
  @Operation(
      summary = "알림·공지 모두 읽음 처리",
      description = """
          ## 인증(JWT): **필요**

          ## 요청 파라미터
          - **`category`**: GENERAL / NOTICE (비우면 두 탭 모두)

          ## 설명
          - 성공 시 204(본문 없음).
          """
  )
  void markAllRead(@AuthMember LoginMember loginMember, @RequestParam(required = false) String category);
}
