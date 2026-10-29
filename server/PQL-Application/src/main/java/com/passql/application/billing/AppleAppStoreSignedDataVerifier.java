package com.passql.application.billing;

import com.apple.itunes.storekit.model.Data;
import com.apple.itunes.storekit.model.Environment;
import com.apple.itunes.storekit.model.JWSTransactionDecodedPayload;
import com.apple.itunes.storekit.model.ResponseBodyV2DecodedPayload;
import com.apple.itunes.storekit.verification.SignedDataVerifier;
import com.apple.itunes.storekit.verification.VerificationException;
import com.apple.itunes.storekit.verification.VerificationStatus;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * App Store JWS 검증 구현 (Apple app-store-server-library SignedDataVerifier)
 * Apple 루트 인증서(classpath) > 운영·샌드박스 검증기 2개, 운영 먼저 > 환경 불일치면 샌드박스(TestFlight·심사), 온라인 폐기 확인 끔
 */
@Slf4j
@Component
public class AppleAppStoreSignedDataVerifier implements AppStoreSignedDataVerifier {

    // iOS 앱 번들 ID (App Store Connect 앱 정보)
    static final String BUNDLE_ID = StoreAppIdentifier.APPLICATION_ID;
    // App Store Connect 앱 Apple ID (운영 환경 검증에 필수)
    static final long APP_APPLE_ID = 6762165005L;
    // Apple 루트 인증서 (공개 인증서, https://www.apple.com/certificateauthority/)
    private static final List<String> APPLE_ROOT_CERTIFICATE_PATHS = List.of(
        "apple-root-certificates/AppleRootCA-G3.cer",
        "apple-root-certificates/AppleIncRootCertificate.cer");
    // 온라인 인증서 폐기 확인 (Apple OCSP 호출, 끔)
    private static final boolean IS_ONLINE_CHECK_ENABLED = false;

    private final SignedDataVerifier productionVerifier;
    private final SignedDataVerifier sandboxVerifier;

    public AppleAppStoreSignedDataVerifier() {
        List<byte[]> rootCertificates = readRootCertificates();
        this.productionVerifier = buildVerifier(rootCertificates, Environment.PRODUCTION);
        this.sandboxVerifier = buildVerifier(rootCertificates, Environment.SANDBOX);
    }

    @Override
    public AppStoreTransaction verifyTransaction(String signedTransaction) {
        return verifyInProductionThenSandbox("transaction",
            verifier -> toAppStoreTransaction(verifier.verifyAndDecodeTransaction(signedTransaction)));
    }

    @Override
    public AppStoreNotification verifyNotification(String signedPayload) {
        return verifyInProductionThenSandbox("notification", verifier -> {
            ResponseBodyV2DecodedPayload payload = verifier.verifyAndDecodeNotification(signedPayload);
            // 담긴 거래는 알림과 같은 환경 검증기로 (거래 없는 알림은 null)
            Data data = payload.getData();
            AppStoreTransaction transaction = data != null && StringUtils.hasText(data.getSignedTransactionInfo())
                ? toAppStoreTransaction(verifier.verifyAndDecodeTransaction(data.getSignedTransactionInfo()))
                : null;
            return new AppStoreNotification(payload.getNotificationUUID(), payload.getRawNotificationType(),
                payload.getRawSubtype(), transaction);
        });
    }

    /** 운영 검증기 > 환경 불일치(INVALID_ENVIRONMENT)일 때만 샌드박스 검증기, 그 외 실패는 바로 400 */
    private <T> T verifyInProductionThenSandbox(String operation, VerifyingCall<T> verifyingCall) {
        try {
            return verifyingCall.verify(productionVerifier);
        } catch (VerificationException exception) {
            if (exception.getStatus() != VerificationStatus.INVALID_ENVIRONMENT) {
                throw toInvalidInput(operation, exception.getStatus().name());
            }
        } catch (RuntimeException exception) {
            throw toInvalidInput(operation, exception.getClass().getSimpleName());
        }
        try {
            return verifyingCall.verify(sandboxVerifier);
        } catch (VerificationException exception) {
            throw toInvalidInput(operation, exception.getStatus().name());
        } catch (RuntimeException exception) {
            throw toInvalidInput(operation, exception.getClass().getSimpleName());
        }
    }

    /** 검증 실패(서명·번들 ID·환경·형식) > 원인 이름만 기록, 400 INVALID_INPUT_VALUE (JWS 원문 로그 금지) */
    private static CustomException toInvalidInput(String operation, String failureReason) {
        log.warn("[billing] app store verification failed : operation={}, reason={}", operation, failureReason);
        return new CustomException(ErrorCode.INVALID_INPUT_VALUE);
    }

    /** Apple 거래 페이로드 > 서비스 거래 (밀리초 시각 > Instant, price 밀리 단위 > 마이크로 단위) */
    private static AppStoreTransaction toAppStoreTransaction(JWSTransactionDecodedPayload payload) {
        return new AppStoreTransaction(payload.getTransactionId(), payload.getOriginalTransactionId(),
            payload.getBundleId(), payload.getProductId(), payload.getRawType(), toInstant(payload.getPurchaseDate()),
            payload.getAppAccountToken(), toInstant(payload.getRevocationDate()), payload.getRawEnvironment(),
            StorePrice.fromAppStoreMilliunits(payload.getPrice(), payload.getCurrency()));
    }

    private static Instant toInstant(Long epochMilliseconds) {
        return epochMilliseconds != null ? Instant.ofEpochMilli(epochMilliseconds) : null;
    }

    /** 환경별 검증기 (번들 ID·앱 Apple ID·환경을 라이브러리가 함께 검사) */
    private static SignedDataVerifier buildVerifier(List<byte[]> rootCertificates, Environment environment) {
        Set<InputStream> rootCertificateStreams = rootCertificates.stream()
            .map(ByteArrayInputStream::new)
            .collect(Collectors.toSet());
        return new SignedDataVerifier(rootCertificateStreams, BUNDLE_ID, APP_APPLE_ID, environment, IS_ONLINE_CHECK_ENABLED);
    }

    /** classpath 루트 인증서 > 바이트 (검증기마다 새 스트림을 만들기 위해 바이트로 보관) */
    private static List<byte[]> readRootCertificates() {
        return APPLE_ROOT_CERTIFICATE_PATHS.stream().map(path -> {
            try (InputStream inputStream = new ClassPathResource(path).getInputStream()) {
                return inputStream.readAllBytes();
            } catch (IOException exception) {
                throw new UncheckedIOException("apple root certificate not found: " + path, exception);
            }
        }).toList();
    }

    /** 검증기 1개로 해석하는 호출 (VerificationException 전달) */
    @FunctionalInterface
    private interface VerifyingCall<T> {
        T verify(SignedDataVerifier verifier) throws VerificationException;
    }
}
