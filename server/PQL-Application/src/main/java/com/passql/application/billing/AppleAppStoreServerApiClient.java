package com.passql.application.billing;

import com.apple.itunes.storekit.client.APIException;
import com.apple.itunes.storekit.client.AppStoreServerAPIClient;
import com.apple.itunes.storekit.model.ConsumptionRequest;
import com.apple.itunes.storekit.model.DeliveryStatus;
import com.apple.itunes.storekit.model.Environment;
import com.apple.itunes.storekit.model.TransactionInfoResponse;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.EnumMap;
import java.util.Map;
import java.util.Optional;

/**
 * App Store Server API 구현 (Apple app-store-server-library AppStoreServerAPIClient, ES256 JWT 서명 포함)
 * 키: 환경 설정 passql.billing.app-store.server-api.* (개인 키는 파일 경로 > base64 순), 없으면 호출 없이 isConfigured false
 * 환경별 클라이언트 지연 생성 (운영 api.storekit.itunes.apple.com, 샌드박스 api.storekit-sandbox.itunes.apple.com)
 */
@Slf4j
@Component
public class AppleAppStoreServerApiClient implements AppStoreServerApiClient {

    // 거래 없음 HTTP 상태 (TRANSACTION_ID_NOT_FOUND 등)
    private static final int NOT_FOUND_STATUS_CODE = 404;
    // 거래 환경 원문 (AppStoreTransaction.environment, 소비 정보 응답 환경 선택)
    private static final String SANDBOX_ENVIRONMENT_NAME = "Sandbox";
    // PEM 개인 키 시작 줄 (base64 값이 이미 PEM 원문인 경우 구분)
    private static final String PEM_PRIVATE_KEY_HEADER = "-----BEGIN PRIVATE KEY-----";

    private final String issuerId;
    private final String keyId;
    private final String privateKeyPem;
    private final AppStoreSignedDataVerifier appStoreSignedDataVerifier;
    private final Map<Environment, AppStoreServerAPIClient> clientByEnvironment = new EnumMap<>(Environment.class);

    public AppleAppStoreServerApiClient(
            @Value("${passql.billing.app-store.server-api.issuer-id:}") String issuerId,
            @Value("${passql.billing.app-store.server-api.key-id:}") String keyId,
            @Value("${passql.billing.app-store.server-api.private-key-path:}") String privateKeyPath,
            @Value("${passql.billing.app-store.server-api.private-key-base64:}") String privateKeyBase64,
            AppStoreSignedDataVerifier appStoreSignedDataVerifier) {
        this.issuerId = issuerId.trim();
        this.keyId = keyId.trim();
        this.privateKeyPem = readPrivateKeyPem(privateKeyPath.trim(), privateKeyBase64.trim());
        this.appStoreSignedDataVerifier = appStoreSignedDataVerifier;
        log.info("[billing] app store server api : configured={}", isConfigured());
    }

    @Override
    public boolean isConfigured() {
        return StringUtils.hasText(issuerId) && StringUtils.hasText(keyId) && StringUtils.hasText(privateKeyPem);
    }

    @Override
    public Optional<AppStoreTransaction> findTransaction(String transactionId, boolean isSandboxFallbackEnabled) {
        Optional<AppStoreTransaction> productionTransaction = findTransactionIn(Environment.PRODUCTION, transactionId);
        if (productionTransaction.isPresent() || !isSandboxFallbackEnabled) {
            return productionTransaction;
        }
        return findTransactionIn(Environment.SANDBOX, transactionId);
    }

    @Override
    public void sendConsumptionInformation(String transactionId, String environment,
                                           AppStoreConsumptionInformation information) {
        Environment targetEnvironment = SANDBOX_ENVIRONMENT_NAME.equalsIgnoreCase(environment)
            ? Environment.SANDBOX : Environment.PRODUCTION;
        ConsumptionRequest consumptionRequest = new ConsumptionRequest(information.isCustomerConsented(),
            information.isDelivered() ? DeliveryStatus.DELIVERED : DeliveryStatus.UNDELIVERED_OTHER,
            information.isSampleContentProvided())
            .consumptionPercentage(information.consumptionPercentageMilliunits());
        try {
            getClient(targetEnvironment).sendConsumptionInformation(transactionId, consumptionRequest);
        } catch (APIException exception) {
            throw toExternalApiError("send consumption", exception.getHttpStatusCode());
        } catch (IOException exception) {
            throw toExternalApiError("send consumption", exception.getClass().getSimpleName());
        }
    }

    /** 환경 1곳 거래 조회 > 서명 검증 (404 > empty) */
    private Optional<AppStoreTransaction> findTransactionIn(Environment environment, String transactionId) {
        TransactionInfoResponse response;
        try {
            response = getClient(environment).getTransactionInfo(transactionId);
        } catch (APIException exception) {
            if (exception.getHttpStatusCode() == NOT_FOUND_STATUS_CODE) {
                return Optional.empty();
            }
            throw toExternalApiError("get transaction " + environment.name(), exception.getHttpStatusCode());
        } catch (IOException exception) {
            throw toExternalApiError("get transaction " + environment.name(), exception.getClass().getSimpleName());
        }
        if (response == null || !StringUtils.hasText(response.getSignedTransactionInfo())) {
            return Optional.empty();
        }
        return Optional.of(appStoreSignedDataVerifier.verifyTransaction(response.getSignedTransactionInfo()));
    }

    /** 환경별 클라이언트 (첫 호출 때 생성, 키 형식 오류 > EXTERNAL_API_ERROR) */
    private synchronized AppStoreServerAPIClient getClient(Environment environment) {
        if (!isConfigured()) {
            throw new CustomException(ErrorCode.EXTERNAL_API_ERROR);
        }
        AppStoreServerAPIClient client = clientByEnvironment.get(environment);
        if (client != null) {
            return client;
        }
        try {
            client = new AppStoreServerAPIClient(privateKeyPem, keyId, issuerId,
                AppleAppStoreSignedDataVerifier.BUNDLE_ID, environment);
        } catch (RuntimeException exception) {
            throw toExternalApiError("create client", exception.getClass().getSimpleName());
        }
        clientByEnvironment.put(environment, client);
        return client;
    }

    /** 실패 원인 종류·상태 코드만 기록 (거래 응답·키 원문 로그 금지) */
    private static CustomException toExternalApiError(String operation, Object cause) {
        log.warn("[billing] app store server api failed : operation={}, cause={}", operation, cause);
        return new CustomException(ErrorCode.EXTERNAL_API_ERROR);
    }

    /** 개인 키 PEM: 파일 경로 > base64(p8 파일 내용, PEM 원문도 허용) > 빈 값 (읽기 실패도 빈 값 = 미설정) */
    private static String readPrivateKeyPem(String privateKeyPath, String privateKeyBase64) {
        if (StringUtils.hasText(privateKeyPath)) {
            try {
                return Files.readString(Path.of(privateKeyPath), StandardCharsets.UTF_8).trim();
            } catch (IOException | RuntimeException exception) {
                log.warn("[billing] app store server api key read failed : cause={}", exception.getClass().getSimpleName());
                return "";
            }
        }
        if (!StringUtils.hasText(privateKeyBase64)) {
            return "";
        }
        if (privateKeyBase64.contains(PEM_PRIVATE_KEY_HEADER)) {
            return privateKeyBase64;
        }
        try {
            return new String(Base64.getMimeDecoder().decode(privateKeyBase64), StandardCharsets.UTF_8).trim();
        } catch (IllegalArgumentException exception) {
            log.warn("[billing] app store server api key decode failed : invalid base64");
            return "";
        }
    }
}
