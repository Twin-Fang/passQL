import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { signInWithPopup } from "firebase/auth";
import { firebaseAuth, googleProvider, appleProvider } from "../lib/firebase";
import { fetchSocialLoginConfig, login, type AuthProvider, type AuthorizationCodeProvider } from "../api/auth";
import { buildAuthorizeUrl } from "../lib/socialLoginRedirect";
import { useAuthStore } from "../stores/authStore";
import { ApiError } from "../api/client";
import type { LegalType } from "../api/legal";
import LegalModal from "../components/LegalModal";
import { AppleIcon, GithubIcon, GoogleIcon, KakaoIcon, NaverIcon } from "../components/SocialLoginIcons";
import logo from "../assets/logo/logo.png";

// 내부 enum(APPLE·KAKAO) 대신 사용자에게 보일 제공자 이름 (#401)
const PROVIDER_LABEL: Record<AuthProvider, string> = {
  GOOGLE: "Google",
  KAKAO: "카카오",
  NAVER: "네이버",
  GITHUB: "GitHub",
  APPLE: "Apple",
};

export default function Login() {
  const navigate = useNavigate();
  const setTokens = useAuthStore((s) => s.setTokens);
  const [loadingProvider, setLoadingProvider] = useState<AuthProvider | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [legalModal, setLegalModal] = useState<LegalType | null>(null);

  const isLoading = loadingProvider !== null;

  /** 로그인 성공 응답 > 토큰 저장 > 홈 */
  const completeLogin = (response: Awaited<ReturnType<typeof login>>) => {
    setTokens({
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      memberUuid: response.memberUuid,
      nickname: response.nickname,
    });
    navigate("/", { replace: true });
  };

  /** Firebase 팝업 로그인 (Google·Apple): 팝업 > ID 토큰 > 서버 로그인 */
  const handleFirebaseLogin = async (provider: "GOOGLE" | "APPLE") => {
    setLoadingProvider(provider);
    setError(null);
    try {
      const result = await signInWithPopup(firebaseAuth, provider === "GOOGLE" ? googleProvider : appleProvider);
      const idToken = await result.user.getIdToken();
      completeLogin(await login({ authProvider: provider, idToken }));
    } catch (err) {
      if (err instanceof ApiError) {
        setError("로그인 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
      } else if (err instanceof Error && err.message.includes("popup-closed-by-user")) {
        // 사용자가 팝업을 직접 닫은 경우 — 에러 메시지 불필요
      } else if (err instanceof Error && err.message.includes("operation-not-allowed")) {
        // 웹 Firebase 에 이 제공자가 아직 설정되지 않음
        setError(`${PROVIDER_LABEL[provider]} 로그인은 준비 중입니다.`);
      } else {
        setError("로그인에 실패했습니다. 다시 시도해주세요.");
      }
    } finally {
      setLoadingProvider(null);
    }
  };

  /** 인가 코드 로그인 (카카오·네이버·GitHub): 서버 공개 설정 확인 > 제공자 인가 페이지로 이동 (#509) */
  const handleAuthorizationCodeLogin = async (provider: AuthorizationCodeProvider) => {
    setLoadingProvider(provider);
    setError(null);
    try {
      const configs = await fetchSocialLoginConfig();
      const config = configs.find((item) => item.authProvider === provider);
      if (!config?.isEnabled || !config.clientId) {
        setError(`${PROVIDER_LABEL[provider]} 로그인은 준비 중입니다.`);
        setLoadingProvider(null);
        return;
      }
      // 페이지를 떠나므로 로딩 표시는 그대로 둔다
      window.location.assign(await buildAuthorizeUrl(provider, config.clientId));
    } catch {
      setError("로그인에 실패했습니다. 다시 시도해주세요.");
      setLoadingProvider(null);
    }
  };

  return (
    <div className="min-h-screen bg-surface grid place-items-center px-4">
      <div className="w-full max-w-sm">
        {/* 로고 */}
        <div className="flex flex-col items-center mb-10">
          <img src={logo} alt="passQL" className="h-10 mb-3" />
          <p className="text-text-secondary text-sm text-center">
            SQL 자격증 합격을 위한 AI 문제풀이
          </p>
        </div>

        {/* 로그인 카드 */}
        <div className="w-full bg-surface-card border border-border rounded-xl p-8">
          <div className="flex flex-col gap-3 w-full">
            <button
              onClick={() => handleFirebaseLogin("GOOGLE")}
              disabled={isLoading}
              className="btn-social btn-social--google"
            >
              {loadingProvider === "GOOGLE"
                ? <span className="loading loading-spinner loading-sm" />
                : <GoogleIcon />
              }
              Google로 계속하기
            </button>

            <button
              onClick={() => handleAuthorizationCodeLogin("KAKAO")}
              disabled={isLoading}
              className="btn-social btn-social--kakao"
            >
              {loadingProvider === "KAKAO"
                ? <span className="loading loading-spinner loading-sm" />
                : <KakaoIcon />
              }
              카카오로 계속하기
            </button>

            <button
              onClick={() => handleAuthorizationCodeLogin("NAVER")}
              disabled={isLoading}
              className="btn-social btn-social--naver"
            >
              {loadingProvider === "NAVER"
                ? <span className="loading loading-spinner loading-sm" />
                : <NaverIcon />
              }
              네이버로 계속하기
            </button>

            <button
              onClick={() => handleAuthorizationCodeLogin("GITHUB")}
              disabled={isLoading}
              className="btn-social btn-social--github"
            >
              {loadingProvider === "GITHUB"
                ? <span className="loading loading-spinner loading-sm" />
                : <GithubIcon />
              }
              GitHub로 계속하기
            </button>

            <button
              onClick={() => handleFirebaseLogin("APPLE")}
              disabled={isLoading}
              className="btn-social btn-social--apple"
            >
              {loadingProvider === "APPLE"
                ? <span className="loading loading-spinner loading-sm" />
                : <AppleIcon />
              }
              Apple로 계속하기
            </button>
          </div>

          {/* 자리를 미리 잡아 오류가 떠도 카드가 위로 밀리지 않게 하고, 대비 AA(4.5:1) 이상 색을 쓴다 (#401) */}
          <p className="mt-4 min-h-5 text-semantic-error-text text-sm text-center" role="alert" aria-live="polite">
            {error}
          </p>
        </div>

        {/* 약관 동의 안내 */}
        {/* caption 색은 배경 대비 AA 미달 > secondary 사용 (#401) */}
        <p className="mt-6 text-center text-text-secondary text-xs">
          로그인하면{" "}
          <button
            type="button"
            className="inline-block py-3.5 -my-3.5 underline underline-offset-2 hover:text-text-primary transition-colors"
            onClick={() => setLegalModal("TERMS_OF_SERVICE")}
          >
            이용약관
          </button>
          {" "}및{" "}
          <button
            type="button"
            className="inline-block py-3.5 -my-3.5 underline underline-offset-2 hover:text-text-primary transition-colors"
            onClick={() => setLegalModal("PRIVACY_POLICY")}
          >
            개인정보처리방침
          </button>
          에 동의하게 됩니다
        </p>
      </div>

      {/* daisyUI 반응형 모달 — 모바일 하단 시트, 데스크톱 중앙 */}
      {legalModal !== null && (
        <LegalModal type={legalModal} onClose={() => setLegalModal(null)} />
      )}
    </div>
  );
}
