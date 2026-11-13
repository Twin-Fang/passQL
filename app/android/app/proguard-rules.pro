# 앱 R8 규칙 (릴리스·테스트 빌드 코드 줄이기)

# flutter_naver_login 2.1.1 은 네이버 SDK 5.10 클래스를 참조한다 (5.12 에서 패키지가 바뀌어 없음).
# Android 네이버 로그인은 MainActivity 채널로 SDK 5.12 를 직접 부르고 플러그인 로그인 경로는 쓰지 않아 경고만 끈다 (#942)
-dontwarn com.navercorp.nid.oauth.NidOAuthErrorCode
-dontwarn com.navercorp.nid.oauth.NidOAuthLogin
-dontwarn com.navercorp.nid.oauth.NidOAuthLoginState
-dontwarn com.navercorp.nid.oauth.OAuthLoginCallback
-dontwarn com.navercorp.nid.profile.**

# 네이버 SDK 5.12 는 Retrofit 프록시로 서비스 인터페이스를 만든다(NidServiceLocator 초기화).
# R8 full mode 가 구현 없는 인터페이스로 보고 형변환을 throw ClassCastException 으로 바꿔 로그인 시 앱 종료 (#942)
-keep class com.navercorp.nid.** { *; }
-keep interface com.navercorp.nid.** { *; }
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
