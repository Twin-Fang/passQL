package com.passql.application.monitor;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;

/**
 * Slack Incoming Webhook 발송: 허용 주소 확인 > 텍스트 POST (실패는 false, 웹훅 URL 은 로그에 남기지 않음)
 */
@Slf4j
@Component
public class SlackWebhookClient {

    // 허용 웹훅 주소 접두사 (Slack 외 주소로 나가지 않게)
    private static final String ALLOWED_WEBHOOK_URL_PREFIX = "https://hooks.slack.com/";
    // 발송 제한 시간 (초)
    private static final long REQUEST_TIMEOUT_SECONDS = 5;

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(REQUEST_TIMEOUT_SECONDS))
            .build();
    private final ObjectMapper objectMapper = new ObjectMapper();

    /** Slack 웹훅 주소 형식인지 */
    public static boolean isAllowedWebhookUrl(String webhookUrl) {
        return webhookUrl != null && webhookUrl.startsWith(ALLOWED_WEBHOOK_URL_PREFIX);
    }

    /** 텍스트 1건 발송, 성공 true (주소 불허·HTTP 2xx 아님·예외는 false) */
    public boolean sendText(String webhookUrl, String text) {
        if (!isAllowedWebhookUrl(webhookUrl)) {
            log.warn("[monitor alert] slack send skipped : webhook url is not a slack address");
            return false;
        }
        try {
            HttpRequest request = HttpRequest.newBuilder(URI.create(webhookUrl))
                    .timeout(Duration.ofSeconds(REQUEST_TIMEOUT_SECONDS))
                    .header("Content-Type", "application/json; charset=UTF-8")
                    .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(Map.of("text", text))))
                    .build();
            HttpResponse<Void> response = httpClient.send(request, HttpResponse.BodyHandlers.discarding());
            if (response.statusCode() / 100 != 2) {
                log.warn("[monitor alert] slack send failed : status={}", response.statusCode());
                return false;
            }
            return true;
        } catch (InterruptedException interruptedException) {
            Thread.currentThread().interrupt();
            return false;
        } catch (Exception exception) {
            // 예외 원문에 URL 이 섞일 수 있어 클래스 이름만
            log.warn("[monitor alert] slack send failed : {}", exception.getClass().getSimpleName());
            return false;
        }
    }
}
