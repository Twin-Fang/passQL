package com.passql.application.billing;

import com.google.api.client.googleapis.json.GoogleJsonResponseException;
import com.google.api.client.http.HttpRequestInitializer;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.androidpublisher.AndroidPublisher;
import com.google.api.services.androidpublisher.AndroidPublisherScopes;
import com.google.api.services.androidpublisher.model.Money;
import com.google.api.services.androidpublisher.model.Order;
import com.google.api.services.androidpublisher.model.ProductPurchase;
import com.google.api.services.androidpublisher.model.VoidedPurchase;
import com.google.api.services.androidpublisher.model.VoidedPurchasesListResponse;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import com.passql.meta.constant.AppSettingKeys;
import com.passql.meta.service.AppSettingService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Google Play Developer API 구현: 서비스 계정 키(app_setting SECRET) > AndroidPublisher 지연 생성
 * 키가 바뀌면 다시 생성, 예외는 원인 없이 CustomException 으로 변환 (Play 오류 문구에 구매 토큰 URL 포함)
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class GooglePlayDeveloperApiClient implements PlayDeveloperApiClient {

    // Play 앱 패키지 이름
    static final String PACKAGE_NAME = StoreAppIdentifier.APPLICATION_ID;
    // Play 요청 연결·응답 대기 시간 (밀리초)
    private static final int REQUEST_TIMEOUT_MILLISECONDS = 10_000;
    // 잘못된 구매 토큰·상품으로 Play 가 돌려주는 상태 코드 (요청 오류로 취급)
    private static final Set<Integer> INVALID_PURCHASE_STATUS_CODES = Set.of(400, 404, 410);
    // Play API 호출 앱 이름 (User-Agent)
    private static final String APPLICATION_NAME = "passQL";

    private final AppSettingService appSettingService;

    // 마지막으로 만든 클라이언트와 그때 쓴 키 (키가 바뀌면 다시 생성)
    private AndroidPublisher cachedAndroidPublisher;
    private String cachedServiceAccountJson;

    @Override
    public boolean isConfigured() {
        return StringUtils.hasText(readServiceAccountJson());
    }

    @Override
    public PlayPurchaseSnapshot getProductPurchase(String productId, String purchaseToken) {
        try {
            ProductPurchase purchase = getAndroidPublisher().purchases().products()
                .get(PACKAGE_NAME, productId, purchaseToken).execute();
            // 구매 시각 없으면 null (서비스가 지금 시각으로 대신)
            Instant purchasedAt = purchase.getPurchaseTimeMillis() != null
                ? Instant.ofEpochMilli(purchase.getPurchaseTimeMillis())
                : null;
            return new PlayPurchaseSnapshot(
                purchase.getOrderId(),
                purchase.getPurchaseState() != null ? purchase.getPurchaseState() : -1,
                purchase.getConsumptionState() != null ? purchase.getConsumptionState() : 0,
                purchasedAt,
                purchase.getObfuscatedExternalAccountId());
        } catch (IOException exception) {
            throw toCustomException("get purchase", exception);
        }
    }

    @Override
    public Optional<StorePrice> findOrderPrice(String orderId) {
        try {
            Order order = getAndroidPublisher().orders().get(PACKAGE_NAME, orderId).execute();
            Money total = order.getTotal();
            if (total == null) {
                log.warn("[billing] play order price missing : order={}", orderId);
                return Optional.empty();
            }
            return Optional.ofNullable(StorePrice.fromPlayMoney(total.getUnits(), total.getNanos(), total.getCurrencyCode()));
        } catch (IOException | CustomException exception) {
            // 상태 코드·원인 이름만 기록 (403: 서비스 계정에 재무 데이터 보기 권한 없음)
            String failureReason = exception instanceof GoogleJsonResponseException responseException
                ? String.valueOf(responseException.getStatusCode())
                : exception.getClass().getSimpleName();
            log.warn("[billing] play order price unavailable : order={}, reason={}", orderId, failureReason);
            return Optional.empty();
        }
    }

    @Override
    public void consume(String productId, String purchaseToken) {
        try {
            getAndroidPublisher().purchases().products().consume(PACKAGE_NAME, productId, purchaseToken).execute();
        } catch (IOException exception) {
            throw toCustomException("consume", exception);
        }
    }

    @Override
    public List<String> listVoidedPurchaseTokens(Instant since) {
        List<String> voidedPurchaseTokens = new ArrayList<>();
        String nextPageToken = null;
        try {
            // 페이지 끝까지 조회 (기본 1페이지 1,000건)
            do {
                VoidedPurchasesListResponse response = getAndroidPublisher().purchases().voidedpurchases()
                    .list(PACKAGE_NAME)
                    .setStartTime(since.toEpochMilli())
                    .setToken(nextPageToken)
                    .execute();
                if (response.getVoidedPurchases() != null) {
                    response.getVoidedPurchases().stream()
                        .map(VoidedPurchase::getPurchaseToken)
                        .filter(StringUtils::hasText)
                        .forEach(voidedPurchaseTokens::add);
                }
                nextPageToken = response.getTokenPagination() != null
                    ? response.getTokenPagination().getNextPageToken()
                    : null;
            } while (StringUtils.hasText(nextPageToken));
        } catch (IOException exception) {
            throw toCustomException("list voided purchases", exception);
        }
        return voidedPurchaseTokens;
    }

    /** 키 확인 > 키가 같으면 기존 클라이언트, 바뀌었으면 새로 생성 (키 없음 EXTERNAL_API_ERROR) */
    private synchronized AndroidPublisher getAndroidPublisher() {
        String serviceAccountJson = readServiceAccountJson();
        if (!StringUtils.hasText(serviceAccountJson)) {
            log.warn("[billing] play api unavailable : service account not configured");
            throw new CustomException(ErrorCode.EXTERNAL_API_ERROR);
        }
        if (cachedAndroidPublisher != null && serviceAccountJson.equals(cachedServiceAccountJson)) {
            return cachedAndroidPublisher;
        }
        cachedAndroidPublisher = buildAndroidPublisher(serviceAccountJson);
        cachedServiceAccountJson = serviceAccountJson;
        log.info("[billing] play api client created");
        return cachedAndroidPublisher;
    }

    /** 서비스 계정 키 > androidpublisher 범위 인증 > 요청 대기 시간 설정 */
    private static AndroidPublisher buildAndroidPublisher(String serviceAccountJson) {
        GoogleCredentials credentials;
        try {
            credentials = GoogleCredentials
                .fromStream(new ByteArrayInputStream(serviceAccountJson.getBytes(StandardCharsets.UTF_8)))
                .createScoped(AndroidPublisherScopes.ANDROIDPUBLISHER);
        } catch (IOException | RuntimeException exception) {
            log.warn("[billing] play api unavailable : invalid service account, cause={}", exception.getClass().getSimpleName());
            throw new CustomException(ErrorCode.EXTERNAL_API_ERROR);
        }
        HttpCredentialsAdapter credentialsAdapter = new HttpCredentialsAdapter(credentials);
        HttpRequestInitializer requestInitializer = request -> {
            credentialsAdapter.initialize(request);
            request.setConnectTimeout(REQUEST_TIMEOUT_MILLISECONDS);
            request.setReadTimeout(REQUEST_TIMEOUT_MILLISECONDS);
        };
        return new AndroidPublisher.Builder(new NetHttpTransport(), GsonFactory.getDefaultInstance(), requestInitializer)
            .setApplicationName(APPLICATION_NAME)
            .build();
    }

    /** 서비스 계정 키 평문 (행 없음 > 빈 값) */
    private String readServiceAccountJson() {
        try {
            return appSettingService.getSecret(AppSettingKeys.BILLING_PLAY_SERVICE_ACCOUNT_JSON);
        } catch (CustomException exception) {
            if (exception.getErrorCode() == ErrorCode.SETTING_NOT_FOUND) {
                return "";
            }
            throw exception;
        }
    }

    /** Play 오류 > 상태 코드만 기록, 잘못된 토큰·상품은 400, 그 외 502 (원인 예외는 붙이지 않음) */
    private static CustomException toCustomException(String operation, IOException exception) {
        if (exception instanceof GoogleJsonResponseException responseException) {
            int statusCode = responseException.getStatusCode();
            log.warn("[billing] play api failed : operation={}, status={}", operation, statusCode);
            if (INVALID_PURCHASE_STATUS_CODES.contains(statusCode)) {
                return new CustomException(ErrorCode.INVALID_INPUT_VALUE);
            }
            return new CustomException(ErrorCode.EXTERNAL_API_ERROR);
        }
        log.warn("[billing] play api failed : operation={}, cause={}", operation, exception.getClass().getSimpleName());
        return new CustomException(ErrorCode.EXTERNAL_API_ERROR);
    }
}
