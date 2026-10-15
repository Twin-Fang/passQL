import { useState, useEffect, useRef } from "react";
import { useNavigate } from "react-router-dom";
import { signInWithPopup } from "firebase/auth";
import { firebaseAuth, googleProvider } from "../lib/firebase";
import { login, type AuthProvider } from "../api/auth";
import { useAuthStore } from "../stores/authStore";
import { ApiError } from "../api/client";
import { fetchLegal, LEGAL_TITLE, type LegalType } from "../api/legal";
import MarkdownText from "../components/MarkdownText";
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

  const handleGoogleLogin = async () => {
    setLoadingProvider("GOOGLE");
    setError(null);
    try {
      const result = await signInWithPopup(firebaseAuth, googleProvider);
      const idToken = await result.user.getIdToken();
      const response = await login({ authProvider: "GOOGLE", idToken });
      setTokens({
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        memberUuid: response.memberUuid,
        nickname: response.nickname,
      });
      navigate("/", { replace: true });
    } catch (err) {
      if (err instanceof ApiError) {
        setError("로그인 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
      } else if (err instanceof Error && err.message.includes("popup-closed-by-user")) {
        // 사용자가 팝업을 직접 닫은 경우 — 에러 메시지 불필요
      } else {
        setError("로그인에 실패했습니다. 다시 시도해주세요.");
      }
    } finally {
      setLoadingProvider(null);
    }
  };

  const handleUnavailable = (provider: AuthProvider) => {
    setError(`${PROVIDER_LABEL[provider]} 로그인은 준비 중입니다.`);
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
              onClick={handleGoogleLogin}
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
              onClick={() => handleUnavailable("KAKAO")}
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
              onClick={() => handleUnavailable("NAVER")}
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
              onClick={() => handleUnavailable("GITHUB")}
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
              onClick={() => handleUnavailable("APPLE")}
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

function LegalModal({
  type,
  onClose,
}: {
  readonly type: LegalType;
  readonly onClose: () => void;
}) {
  const dialogRef = useRef<HTMLDialogElement>(null);
  const [title, setTitle] = useState<string | null>(null);
  const [content, setContent] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState(false);

  // 모달 열기 + 닫힐 때 onClose 연동
  // open 체크: onClose 참조 변경 시 재실행되어도 이미 열린 dialog에 showModal 중복 호출 방지
  useEffect(() => {
    const dialog = dialogRef.current;
    if (!dialog) return;
    if (!dialog.open) dialog.showModal();
    const handleClose = () => onClose();
    dialog.addEventListener("close", handleClose);
    return () => dialog.removeEventListener("close", handleClose);
  }, [onClose]);

  // 다시 시도 버튼이 값을 올려 같은 type으로 재요청하게 한다
  const [retryKey, setRetryKey] = useState(0);

  // 약관 내용 fetch — 모달이 닫혀 언마운트되면 늦게 온 응답은 버린다
  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setFetchError(false);
    fetchLegal(type)
      .then((data) => {
        if (cancelled) return;
        setTitle(data.title);
        setContent(data.content);
      })
      .catch(() => {
        if (!cancelled) setFetchError(true);
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => {
      cancelled = true;
    };
  }, [type, retryKey]);

  return (
    <dialog ref={dialogRef} className="modal modal-bottom sm:modal-middle">
      <div className="modal-box flex flex-col max-h-[80vh] p-0 overflow-hidden">
        {/* 헤더 */}
        <div className="flex items-center justify-between px-5 py-4 border-b border-border shrink-0">
          <h3 className="text-base font-bold text-text-primary">
            {/* 실패해도 사용자가 연 문서 이름을 보여 준다 (#403) */}
            {title ?? LEGAL_TITLE[type]}
          </h3>
          <form method="dialog">
            <button
              type="submit"
              className="btn btn-sm btn-circle btn-ghost text-text-caption"
              aria-label="닫기"
            >
              ✕
            </button>
          </form>
        </div>

        {/* 본문 스크롤 영역 */}
        <div className="overflow-y-auto px-5 py-4 flex-1">
          {loading && (
            <div className="flex justify-center py-8">
              <span className="loading loading-spinner loading-md text-brand" />
            </div>
          )}
          {fetchError && (
            <div className="flex flex-col items-center gap-3 py-8">
              <p className="text-sm text-semantic-error text-center">
                {LEGAL_TITLE[type]}을 불러오지 못했습니다.
              </p>
              <button
                type="button"
                className="btn btn-sm btn-outline border-brand text-brand hover:bg-brand-light hover:border-brand"
                onClick={() => setRetryKey((k) => k + 1)}
              >
                다시 시도
              </button>
            </div>
          )}
          {!loading && !fetchError && content && (
            <div className="prose prose-sm max-w-none text-text-primary">
              <MarkdownText text={content} animated={false} />
            </div>
          )}
          <div className="h-4" />
        </div>
      </div>
      {/* 오버레이 클릭 시 닫기 */}
      <form method="dialog" className="modal-backdrop">
        <button type="submit">닫기</button>
      </form>
    </dialog>
  );
}
