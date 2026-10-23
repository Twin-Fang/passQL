package com.passql.application.billing;

import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;

import java.util.HashMap;
import java.util.Map;

/** 가짜 App Store 검증기: JWS 문자열 > 고정 거래·알림, 등록 안 된 문자열은 서명 실패(400) */
class FakeAppStoreSignedDataVerifier implements AppStoreSignedDataVerifier {

    final Map<String, AppStoreTransaction> transactionBySignedTransaction = new HashMap<>();
    final Map<String, AppStoreNotification> notificationBySignedPayload = new HashMap<>();

    @Override
    public AppStoreTransaction verifyTransaction(String signedTransaction) {
        AppStoreTransaction transaction = transactionBySignedTransaction.get(signedTransaction);
        if (transaction == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return transaction;
    }

    @Override
    public AppStoreNotification verifyNotification(String signedPayload) {
        AppStoreNotification notification = notificationBySignedPayload.get(signedPayload);
        if (notification == null) {
            throw new CustomException(ErrorCode.INVALID_INPUT_VALUE);
        }
        return notification;
    }
}
