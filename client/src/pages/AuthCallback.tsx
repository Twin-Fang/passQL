import { useEffect, useRef, useState } from "react";
import { Link, useNavigate, useParams, useSearchParams } from "react-router-dom";
import { loginWithAuthorizationCode } from "../api/auth";
import { useAuthStore } from "../stores/authStore";
import { callbackUrlOf, isExpectedState, providerFromCallbackPath, takeSavedCodeVerifier } from "../lib/socialLoginRedirect";
import PageLoadingFallback from "../components/PageLoadingFallback";

/**
 * 소셜 인가 콜백 (#509): state 확인 > 인가 코드로 서버 로그인 > 홈
 * 실패하면 안내와 로그인 화면으로 돌아가는 링크
 */
export default function AuthCallback() {
  const navigate = useNavigate();
  const { provider: pathProvider } = useParams();
  const [searchParams] = useSearchParams();
  const setTokens = useAuthStore((s) => s.setTokens);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  // StrictMode 이중 실행에서도 코드는 한 번만 교환 (인가 코드는 1회용)
  const hasRequestedRef = useRef(false);

  useEffect(() => {
    if (hasRequestedRef.current) return;
    hasRequestedRef.current = true;

    const provider = providerFromCallbackPath(pathProvider);
    const code = searchParams.get("code");
    const state = searchParams.get("state");
    // 실패 경로에서도 남지 않도록 검사 전에 꺼냄 (1회용)
    const codeVerifier = takeSavedCodeVerifier() ?? undefined;
    // 사용자가 동의 화면에서 취소했거나 state 가 다르면 교환하지 않는다
    if (!provider || !code || !isExpectedState(state)) {
      setErrorMessage("로그인을 완료하지 못했어요. 다시 시도해 주세요.");
      return;
    }
    loginWithAuthorizationCode({ authProvider: provider, code, redirectUri: callbackUrlOf(provider), state, codeVerifier })
      .then((response) => {
        setTokens({
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          memberUuid: response.memberUuid,
          nickname: response.nickname,
        });
        navigate("/", { replace: true });
      })
      .catch(() => setErrorMessage("로그인 처리 중 오류가 발생했어요. 다시 시도해 주세요."));
  }, [pathProvider, searchParams, setTokens, navigate]);

  if (!errorMessage) return <PageLoadingFallback />;
  return (
    <div className="min-h-screen bg-surface grid place-items-center px-4">
      <div className="text-center">
        <p role="alert" className="text-sm text-text-secondary mb-4">{errorMessage}</p>
        <Link to="/login" replace className="text-sm font-semibold text-brand underline">
          로그인 화면으로
        </Link>
      </div>
    </div>
  );
}
