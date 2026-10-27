package com.passql.ai.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.ai.constant.AiProvider;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.time.Duration;
import java.util.Map;

/**
 * Claude·OpenAI HTTP 호출 공통: JSON 요청 > 응답 JSON, 실패 > AiProviderException (상태 코드·본문 일부)
 */
@Component
public class AiProviderHttpClient {

    // 생성 호출 1회 응답 대기 상한 (30초, Gemini 와 같은 기준)
    private static final int CALL_TIMEOUT_MILLISECONDS = 30_000;
    // 연결 확인 응답 대기 상한 (3초, 관리자·모니터링 화면이 묶이지 않게)
    private static final int VERIFY_TIMEOUT_MILLISECONDS = 3_000;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final RestTemplate callRestTemplate = createRestTemplate(CALL_TIMEOUT_MILLISECONDS);
    private final RestTemplate verifyRestTemplate = createRestTemplate(VERIFY_TIMEOUT_MILLISECONDS);

    /** 생성 호출 (POST JSON) */
    public JsonNode post(AiProvider provider, String url, Map<String, String> headerValues, JsonNode requestBody) {
        return exchange(callRestTemplate, provider, HttpMethod.POST, url, headerValues, requestBody.toString());
    }

    /** 연결 확인 (GET, 짧은 제한 시간) */
    public JsonNode get(AiProvider provider, String url, Map<String, String> headerValues) {
        return exchange(verifyRestTemplate, provider, HttpMethod.GET, url, headerValues, null);
    }

    public ObjectMapper objectMapper() {
        return objectMapper;
    }

    private JsonNode exchange(RestTemplate restTemplate, AiProvider provider, HttpMethod method, String url,
                              Map<String, String> headerValues, String requestBody) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headerValues.forEach(headers::set);
            String responseText = restTemplate.exchange(url, method, new HttpEntity<>(requestBody, headers), String.class).getBody();
            return objectMapper.readTree(responseText == null ? "{}" : responseText);
        } catch (HttpStatusCodeException e) {
            throw new AiProviderException(provider, e.getStatusCode().value(), e.getResponseBodyAsString(), e);
        } catch (RestClientException e) {
            throw new AiProviderException(provider, null, null, e);
        } catch (Exception e) {
            throw new AiProviderException(provider, null, "response parse failed", e);
        }
    }

    private static RestTemplate createRestTemplate(int timeoutMilliseconds) {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(Duration.ofMillis(timeoutMilliseconds));
        requestFactory.setReadTimeout(Duration.ofMillis(timeoutMilliseconds));
        return new RestTemplate(requestFactory);
    }
}
