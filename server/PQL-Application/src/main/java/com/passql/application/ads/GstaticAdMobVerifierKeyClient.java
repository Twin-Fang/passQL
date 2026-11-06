package com.passql.application.ads;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Google 공개키 목록(verifier-keys.json) 조회·캐시: 캐시 24시간 > 모르는 key_id 면 다시 받기(1분 간격 제한)
 * 받기 실패 > 이전 목록 유지, 목록이 비었으면 EXTERNAL_API_ERROR (AdMob 이 콜백을 다시 보내게)
 */
@Slf4j
@Component
public class GstaticAdMobVerifierKeyClient implements AdMobVerifierKeyClient {

    // AdMob 보상형 광고 서버 검증 공개키 목록 (Google 공식 주소)
    static final String VERIFIER_KEYS_URL = "https://www.gstatic.com/admob/reward/verifier-keys.json";
    // 공개키 목록 캐시 유지 시간 (키 교체 주기보다 짧게)
    private static final Duration KEYS_CACHE_DURATION = Duration.ofHours(24);
    // 다시 받기 최소 간격 (위조 key_id 요청으로 Google 을 반복 호출하지 않게)
    private static final Duration MINIMUM_REFETCH_INTERVAL = Duration.ofMinutes(1);
    // 요청 연결·응답 대기 시간
    private static final Duration REQUEST_TIMEOUT = Duration.ofSeconds(10);
    // 공개키 형식: ECDSA P-256 (X.509 SubjectPublicKeyInfo DER, 목록의 base64 필드)
    private static final String KEY_ALGORITHM = "EC";
    private static final int HTTP_STATUS_OK = 200;

    private final HttpClient httpClient;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final Clock clock;

    // 마지막으로 받은 목록 (읽기는 잠금 없이, 바꾸기는 refreshKeys 안에서만)
    private volatile CachedKeys cachedKeys = CachedKeys.EMPTY;

    public GstaticAdMobVerifierKeyClient() {
        this(HttpClient.newBuilder().connectTimeout(REQUEST_TIMEOUT).build(), Clock.systemUTC());
    }

    GstaticAdMobVerifierKeyClient(HttpClient httpClient, Clock clock) {
        this.httpClient = httpClient;
        this.clock = clock;
    }

    @Override
    public Optional<PublicKey> findPublicKey(long keyId) {
        Instant now = clock.instant();
        CachedKeys snapshot = cachedKeys;
        PublicKey cachedKey = snapshot.publicKeyById().get(keyId);
        if (cachedKey != null && !snapshot.isExpired(now)) {
            return Optional.of(cachedKey);
        }
        if (snapshot.canRefetch(now)) {
            snapshot = refreshKeys(now);
        }
        return Optional.ofNullable(snapshot.publicKeyById().get(keyId));
    }

    /** 목록 다시 받기 (동시 요청은 한 번만), 실패 > 이전 목록 유지 후 시도 시각만 기록 */
    private synchronized CachedKeys refreshKeys(Instant now) {
        if (!cachedKeys.canRefetch(now)) {
            return cachedKeys;
        }
        try {
            cachedKeys = new CachedKeys(fetchPublicKeyById(), now, now);
            log.info("[admob ssv] verifier keys refreshed : count={}", cachedKeys.publicKeyById().size());
        } catch (IOException | GeneralSecurityException | IllegalArgumentException e) {
            log.warn("[admob ssv] verifier keys fetch failed, keeping previous : reason={}", e.getClass().getSimpleName());
            cachedKeys = new CachedKeys(cachedKeys.publicKeyById(), cachedKeys.fetchedAt(), now);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            cachedKeys = new CachedKeys(cachedKeys.publicKeyById(), cachedKeys.fetchedAt(), now);
        }
        if (cachedKeys.publicKeyById().isEmpty()) {
            throw new CustomException(ErrorCode.EXTERNAL_API_ERROR);
        }
        return cachedKeys;
    }

    /** GET 목록 > {"keys":[{"keyId":..,"base64":".."}]} > key_id 별 공개키 */
    private Map<Long, PublicKey> fetchPublicKeyById() throws IOException, InterruptedException, GeneralSecurityException {
        HttpRequest request = HttpRequest.newBuilder(URI.create(VERIFIER_KEYS_URL)).timeout(REQUEST_TIMEOUT).GET().build();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != HTTP_STATUS_OK) {
            throw new IOException("unexpected status " + response.statusCode());
        }
        KeyFactory keyFactory = KeyFactory.getInstance(KEY_ALGORITHM);
        Map<Long, PublicKey> publicKeyById = new HashMap<>();
        for (JsonNode keyNode : objectMapper.readTree(response.body()).path("keys")) {
            byte[] encodedKey = Base64.getDecoder().decode(keyNode.path("base64").asText());
            publicKeyById.put(keyNode.path("keyId").asLong(), keyFactory.generatePublic(new X509EncodedKeySpec(encodedKey)));
        }
        return Map.copyOf(publicKeyById);
    }

    /** 받은 목록 + 받은 시각 + 마지막 시도 시각 */
    private record CachedKeys(Map<Long, PublicKey> publicKeyById, Instant fetchedAt, Instant lastAttemptAt) {

        static final CachedKeys EMPTY = new CachedKeys(Map.of(), Instant.EPOCH, Instant.EPOCH);

        boolean isExpired(Instant now) {
            return fetchedAt.plus(KEYS_CACHE_DURATION).isBefore(now);
        }

        boolean canRefetch(Instant now) {
            return !lastAttemptAt.plus(MINIMUM_REFETCH_INTERVAL).isAfter(now);
        }
    }
}
