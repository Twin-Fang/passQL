package com.passql.application.ads;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.PublicKey;
import java.security.Signature;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

/**
 * AdMob 보상형 광고 서버 검증 콜백 서명 확인 (#860): 원본 쿼리 > 서명 대상·서명·key_id 분리 > 공개키 > ECDSA 검증 > 값
 * 서명 대상 = 쿼리 "&signature=" 앞부분 (Google 규격), 뒤는 signature·key_id 두 개만 허용, 실패 > 403 ACCESS_DENIED
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AdMobRewardCallbackVerifier {

    // 쿼리 안 서명 시작 구분 (이 앞까지가 서명 대상)
    private static final String SIGNATURE_SEPARATOR = "&signature=";
    // 서명 뒤 꼬리 파라미터 이름 2개 (순서 고정)
    private static final String SIGNATURE_PARAMETER = "signature";
    private static final String KEY_ID_PARAMETER = "key_id";
    // 서명 대상 안 값 이름 (AdMob 콜백 규격)
    private static final String AD_UNIT_PARAMETER = "ad_unit";
    private static final String USER_ID_PARAMETER = "user_id";
    private static final String CUSTOM_DATA_PARAMETER = "custom_data";
    private static final String TRANSACTION_ID_PARAMETER = "transaction_id";
    // 서명 알고리즘: ECDSA P-256 + SHA-256, DER 인코딩 (웹 안전 base64)
    private static final String SIGNATURE_ALGORITHM = "SHA256withECDSA";
    private static final String PARAMETER_DELIMITER = "&";
    private static final String NAME_VALUE_DELIMITER = "=";

    private final AdMobVerifierKeyClient adMobVerifierKeyClient;

    /** 원본(URL 인코딩 그대로) 쿼리 > 서명 확인한 콜백 값 */
    public AdMobRewardCallback verify(String rawQueryString) {
        if (rawQueryString == null || rawQueryString.isBlank()) {
            throw rejected("empty query");
        }
        int signatureSeparatorIndex = rawQueryString.indexOf(SIGNATURE_SEPARATOR);
        if (signatureSeparatorIndex <= 0) {
            throw rejected("no signature");
        }
        String signedContent = rawQueryString.substring(0, signatureSeparatorIndex);
        Map<String, String> trailingValueByName = parseQuery(rawQueryString.substring(signatureSeparatorIndex + 1));
        if (trailingValueByName.size() != 2 || !trailingValueByName.containsKey(SIGNATURE_PARAMETER)
            || !trailingValueByName.containsKey(KEY_ID_PARAMETER)) {
            throw rejected("unexpected trailing parameters");
        }

        long keyId = parseKeyId(trailingValueByName.get(KEY_ID_PARAMETER));
        byte[] signature = decodeSignature(trailingValueByName.get(SIGNATURE_PARAMETER));
        PublicKey publicKey = adMobVerifierKeyClient.findPublicKey(keyId)
            .orElseThrow(() -> rejected("unknown key id"));
        if (!isSignatureValid(publicKey, signedContent, signature)) {
            throw rejected("signature mismatch");
        }

        Map<String, String> signedValueByName = parseQuery(signedContent);
        return new AdMobRewardCallback(
            signedValueByName.get(AD_UNIT_PARAMETER),
            signedValueByName.get(USER_ID_PARAMETER),
            signedValueByName.get(CUSTOM_DATA_PARAMETER),
            signedValueByName.get(TRANSACTION_ID_PARAMETER));
    }

    /** 공개키 <-> 서명 대상 바이트(UTF-8) 서명 검증 (형식 오류 서명은 불일치) */
    private static boolean isSignatureValid(PublicKey publicKey, String signedContent, byte[] signature) {
        try {
            Signature verifier = Signature.getInstance(SIGNATURE_ALGORITHM);
            verifier.initVerify(publicKey);
            verifier.update(signedContent.getBytes(StandardCharsets.UTF_8));
            return verifier.verify(signature);
        } catch (GeneralSecurityException e) {
            log.warn("[admob ssv] signature check failed : reason={}", e.getClass().getSimpleName());
            return false;
        }
    }

    /** a=1&b=2 > 이름별 디코딩 값 (같은 이름은 처음 값, 형식 오류 > 거부) */
    private static Map<String, String> parseQuery(String query) {
        Map<String, String> valueByName = new HashMap<>();
        for (String pair : query.split(PARAMETER_DELIMITER)) {
            if (pair.isEmpty()) {
                continue;
            }
            int delimiterIndex = pair.indexOf(NAME_VALUE_DELIMITER);
            String name = delimiterIndex < 0 ? pair : pair.substring(0, delimiterIndex);
            String encodedValue = delimiterIndex < 0 ? "" : pair.substring(delimiterIndex + 1);
            valueByName.putIfAbsent(decode(name), decode(encodedValue));
        }
        return valueByName;
    }

    private static String decode(String encodedText) {
        try {
            return URLDecoder.decode(encodedText, StandardCharsets.UTF_8);
        } catch (IllegalArgumentException e) {
            throw rejected("malformed encoding");
        }
    }

    private static long parseKeyId(String keyIdText) {
        try {
            return Long.parseLong(keyIdText);
        } catch (NumberFormatException e) {
            throw rejected("invalid key id");
        }
    }

    /** 웹 안전 base64(패딩 없어도 됨) > 서명 바이트 */
    private static byte[] decodeSignature(String signatureText) {
        try {
            return Base64.getUrlDecoder().decode(signatureText);
        } catch (IllegalArgumentException e) {
            throw rejected("invalid signature encoding");
        }
    }

    private static CustomException rejected(String reason) {
        log.warn("[admob ssv] rejected 403 : {}", reason);
        return new CustomException(ErrorCode.ACCESS_DENIED);
    }
}
