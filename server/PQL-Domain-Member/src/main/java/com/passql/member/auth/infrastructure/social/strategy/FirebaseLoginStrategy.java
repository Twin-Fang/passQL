package com.passql.member.auth.infrastructure.social.strategy;

import com.google.firebase.auth.AuthErrorCode;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.passql.common.exception.CustomException;
import com.passql.common.exception.constant.ErrorCode;
import lombok.RequiredArgsConstructor;

import java.util.Map;

/** Google, Apple 등 Firebase SDK로 idToken을 검증하는 전략의 공통 추상 클래스. */
@RequiredArgsConstructor
public abstract class FirebaseLoginStrategy implements SocialLoginStrategy {

    // Firebase ID 토큰 클레임: firebase.sign_in_provider (google.com, apple.com 등)
    private static final String FIREBASE_CLAIM = "firebase";
    private static final String SIGN_IN_PROVIDER_CLAIM = "sign_in_provider";

    private final FirebaseAuth firebaseAuth;

    /** 이 전략이 받는 Firebase 로그인 제공자 값 (예: google.com) */
    protected abstract String expectedSignInProvider();

    /** Firebase 토큰 검증 > 로그인 제공자 <-> 이 전략 제공자 (다르면 INVALID_SOCIAL_TOKEN) > uid */
    @Override
    public String validateAndGetSocialId(String idToken) {
        FirebaseToken firebaseToken = verifyIdToken(idToken);
        String signInProvider = SocialStrategyResponses.stringOf(
                SocialStrategyResponses.childOf(firebaseToken.getClaims(), FIREBASE_CLAIM), SIGN_IN_PROVIDER_CLAIM);
        if (!expectedSignInProvider().equals(signInProvider)) {
            throw SocialStrategyResponses.rejectedToken(getAuthProvider(), "firebase sign-in provider mismatch");
        }
        return firebaseToken.getUid();
    }

    private FirebaseToken verifyIdToken(String idToken) {
        try {
            return firebaseAuth.verifyIdToken(idToken);
        } catch (FirebaseAuthException e) {
            AuthErrorCode errorCode = e.getAuthErrorCode();
            throw switch (errorCode) {
                case EXPIRED_ID_TOKEN -> new CustomException(ErrorCode.EXPIRED_FIREBASE_TOKEN);
                case INVALID_ID_TOKEN, REVOKED_ID_TOKEN -> new CustomException(ErrorCode.INVALID_FIREBASE_TOKEN);
                default -> new CustomException(ErrorCode.FIREBASE_SERVER_ERROR);
            };
        }
    }
}
