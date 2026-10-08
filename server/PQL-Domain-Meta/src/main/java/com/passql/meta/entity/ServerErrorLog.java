package com.passql.meta.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * 서버 오류 기록 (#440).
 *
 * <p>5xx 응답·처리되지 않은 예외를 관리자 모니터링에서 바로 보기 위한 테이블이다.
 * 상세 스택은 컨테이너 로그(배포 시 볼륨에 보관, #436)에 있고, 여기 남긴 requestId 로 찾아간다.
 * 30일 지난 행은 스케줄러가 지운다.
 */
@Entity
@Table(
    name = "server_error_log",
    indexes = @Index(name = "idx_server_error_log_occurred_at", columnList = "occurred_at")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ServerErrorLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID serverErrorLogUuid;

    @Column(nullable = false)
    private LocalDateTime occurredAt;

    @Column(length = 64)
    private String requestId;

    // 회원 UUID 앞 8자리 — 로그 줄의 mid 와 같은 값이라 그대로 grep 할 수 있다
    @Column(length = 8)
    private String memberId;

    @Column(length = 10, nullable = false)
    private String method;

    @Column(length = 500, nullable = false)
    private String uri;

    @Column(nullable = false)
    private int status;

    @Column(columnDefinition = "TEXT")
    private String detail;

    public static ServerErrorLog of(String requestId, String memberId, String method,
                                    String uri, int status, String detail) {
        ServerErrorLog log = new ServerErrorLog();
        log.occurredAt = LocalDateTime.now();
        log.requestId = requestId;
        log.memberId = memberId;
        log.method = method;
        log.uri = uri;
        log.status = status;
        log.detail = detail;
        return log;
    }
}
