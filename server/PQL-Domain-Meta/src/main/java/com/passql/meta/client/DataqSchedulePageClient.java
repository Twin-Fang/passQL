package com.passql.meta.client;

import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;

/**
 * 데이터자격검정 시험 일정 페이지 HTML 가져오기 (#991, 서버 렌더 HTML, 공식 JSON API 없음)
 * 실패(연결·시간 초과·2xx 아님·크기 초과)는 예외 대신 FetchResult 사유로 돌려줌
 */
@Component
public class DataqSchedulePageClient {

    // 공식 시험 일정 페이지 (SQLD·SQLP 공통, 연도 파라미터 없음 = 그해 일정)
    public static final String OFFICIAL_SCHEDULE_URL = "https://www.dataq.or.kr/www/accept/schedule.do";
    // 연결·응답 제한 (초)
    private static final int CONNECT_TIMEOUT_SECONDS = 10;
    private static final int REQUEST_TIMEOUT_SECONDS = 20;
    // 응답 본문 상한 (2MB, 평소 약 40KB)
    private static final int MAX_BODY_BYTES = 2 * 1024 * 1024;
    // 일반 브라우저 User-Agent (봇 차단 회피용, 서비스 식별 정보 넣지 않음)
    private static final String USER_AGENT =
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36";

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(CONNECT_TIMEOUT_SECONDS))
            .followRedirects(HttpClient.Redirect.NORMAL)
            .build();

    /** 가져오기 결과: 성공이면 html, 실패면 failureDetail (영어, 응답 원문 없음) */
    public record FetchResult(String html, String failureDetail) {
        public boolean isSuccess() {
            return html != null;
        }
    }

    /** 공식 페이지 1회 요청 */
    public FetchResult fetchSchedulePage() {
        HttpRequest request = HttpRequest.newBuilder(URI.create(OFFICIAL_SCHEDULE_URL))
                .timeout(Duration.ofSeconds(REQUEST_TIMEOUT_SECONDS))
                .header("User-Agent", USER_AGENT)
                .header("Accept", "text/html")
                .GET()
                .build();
        try {
            HttpResponse<byte[]> response = httpClient.send(request, HttpResponse.BodyHandlers.ofByteArray());
            if (response.statusCode() / 100 != 2) {
                return new FetchResult(null, "http status " + response.statusCode());
            }
            byte[] body = response.body();
            if (body.length > MAX_BODY_BYTES) {
                return new FetchResult(null, "body too large : " + body.length + " bytes");
            }
            // 공식 페이지는 UTF-8 (meta charset)
            return new FetchResult(new String(body, StandardCharsets.UTF_8), null);
        } catch (IOException e) {
            return new FetchResult(null, "io error : " + e.getClass().getSimpleName());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return new FetchResult(null, "interrupted");
        }
    }
}
