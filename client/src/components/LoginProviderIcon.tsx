import type { AuthProvider } from "../types/api";
import { LOGIN_PROVIDER_LABEL } from "../lib/loginProviderPresentation";
import { AppleIcon, GithubIcon, GoogleIcon, KakaoIcon, NaverIcon } from "./SocialLoginIcons";

interface LoginProviderIconProps {
  readonly provider: AuthProvider;
  /** small: 마이페이지 프로필 아래 줄(16px), 기본: 설정 내 계정 행(20px) */
  readonly isSmall?: boolean;
  /** 옆 글자가 제공자 이름을 말하면 스크린리더 이름 생략 */
  readonly isLabelHidden?: boolean;
}

// 칸 대비 로고 크기 (px): 둘레 여백 확보
const LOGO_SIZE_DEFAULT = 12;
const LOGO_SIZE_SMALL = 10;

// 제공자 > 로그인 버튼 색 클래스 (색 원본 base-controls.css .btn-social--*)
const PROVIDER_COLOR_CLASS: Readonly<Record<AuthProvider, string>> = {
  GOOGLE: "btn-social--google",
  KAKAO: "btn-social--kakao",
  NAVER: "btn-social--naver",
  GITHUB: "btn-social--github",
  APPLE: "btn-social--apple",
};

/** 로그인 제공자 아이콘 (#908): 로그인 버튼과 같은 색 칸 + 로고 */
export default function LoginProviderIcon({ provider, isSmall = false, isLabelHidden = false }: LoginProviderIconProps) {
  const logoSize = isSmall ? LOGO_SIZE_SMALL : LOGO_SIZE_DEFAULT;
  const logo = {
    GOOGLE: <GoogleIcon size={logoSize} />,
    KAKAO: <KakaoIcon size={logoSize} />,
    NAVER: <NaverIcon size={logoSize} />,
    GITHUB: <GithubIcon size={logoSize} />,
    APPLE: <AppleIcon size={logoSize} />,
  }[provider];
  return (
    <span
      className={`login-provider-icon ${isSmall ? "login-provider-icon--small" : ""} ${PROVIDER_COLOR_CLASS[provider]}`}
      role={isLabelHidden ? undefined : "img"}
      aria-label={isLabelHidden ? undefined : LOGIN_PROVIDER_LABEL[provider]}
      aria-hidden={isLabelHidden ? true : undefined}
    >
      {logo}
    </span>
  );
}
