import { useState, useRef, useEffect } from "react";
// Settings는 마이페이지 톱니바퀴로 진입하는 서브페이지 — 닉네임/계정 정보는 MyPage에서 관리, 여기선 문제풀이 모드·이용안내·앱정보·약관·사업자 정보·계정(로그아웃/탈퇴)을 다룸
import { useNavigate } from "react-router-dom";
import { ChevronRight, LogOut, ExternalLink } from "lucide-react";
import { withdraw } from "../api/members";
import ConfirmModal from "../components/ConfirmModal";
import { useAppLinks } from "../hooks/useAppLinks";
import { getRefreshToken } from "../stores/authStore";
import { logout } from "../api/auth";
import { clearMemberSession } from "../lib/memberSession";
import { revokeSocialAccessBeforeWithdraw, type SocialRevokeResult } from "../lib/socialAccountRevoke";
import logo from "../assets/logo/logo.png";
import { useStagger } from "../hooks/useStagger";
import SettingsSection from "../components/SettingsSection";
import SettingsRow from "../components/SettingsRow";
import SubpageLayout from "../components/SubpageLayout";
import LegalModal from "../components/LegalModal";
import { useBusinessInfoLines } from "../hooks/useBusinessInfoLines";
import { LEGAL_TITLE, type LegalType } from "../api/legal";
import { IS_GOOGLE_PLAY_PUBLIC } from "../constants/appStoreRelease";
import { useMember, useUpdateChoiceGenerationMode } from "../hooks/useMember";
import type { ChoiceGenerationMode } from "../types/api";

// 탈퇴 중단 사유 > 안내 문구 (Apple 연결 해제 실패·취소, Apple·Google 계정 불일치)
const WITHDRAW_STOPPED_MESSAGE: Readonly<Record<Exclude<SocialRevokeResult, "READY_TO_WITHDRAW">, string>> = {
  CANCELLED_BY_USER: "Apple 계정 확인을 취소해 탈퇴를 멈췄어요. 탈퇴하려면 다시 시도해 주세요.",
  REVOKE_FAILED: "Apple 연결 해제에 실패해 탈퇴를 멈췄어요. 잠시 후 다시 시도해 주세요.",
  ACCOUNT_MISMATCH: "가입한 계정으로 다시 인증해 주세요.",
};

export default function Settings() {
  const navigate = useNavigate();
  const [isLoggingOut, setIsLoggingOut] = useState(false);
  // 회원 탈퇴 — 앱과 같은 흐름: 확인 → 서버 삭제 성공 시에만 세션 정리 (#433)
  const [withdrawOpen, setWithdrawOpen] = useState(false);
  const [isWithdrawing, setIsWithdrawing] = useState(false);
  const [withdrawError, setWithdrawError] = useState<string | null>(null);
  const { androidUrl, iosUrl, hasAny: hasAppLinks } = useAppLinks();
  // 약관 본문 모달 (로그인 화면과 같은 컴포넌트, #658)
  const [openedLegalType, setOpenedLegalType] = useState<LegalType | null>(null);
  const businessInfoLines = useBusinessInfoLines();
  // 문제풀이 섹션 — 선택지 생성 모드 토글
  const { data: memberData } = useMember();
  const { mutate: updateMode, isPending: isModeUpdating } = useUpdateChoiceGenerationMode();
  const currentMode: ChoiceGenerationMode = memberData?.choiceGenerationMode ?? "PRACTICE";

  const toastTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const stagger = useStagger();
  const s0 = stagger(0); // 이용안내 섹션
  const s1 = stagger(1); // 문제풀이 섹션
  const s2 = stagger(2); // 앱 정보 섹션
  const s3 = stagger(3); // 약관·사업자 정보 섹션
  const s4 = stagger(4); // 로그아웃 섹션
  const s5 = stagger(5); // 로고 + 카피라이트

  useEffect(() => {
    return () => {
      if (toastTimerRef.current) clearTimeout(toastTimerRef.current);
    };
  }, []);

  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      const refreshToken = getRefreshToken();
      if (refreshToken) {
        await logout(refreshToken).catch(() => {});
      }
    } finally {
      // 다음 계정에 이전 회원 캐시·풀이 상태가 비치지 않도록 전부 정리
      clearMemberSession();
      navigate("/login", { replace: true });
    }
  };

  const handleWithdraw = async () => {
    // 제공자를 모르면 Apple 연결 해제를 건너뛸 수 있어 탈퇴하지 않는다
    const authProvider = memberData?.authProvider;
    const providerUserId = memberData?.providerUserId;
    setWithdrawOpen(false);
    setWithdrawError(null);
    if (!authProvider || !providerUserId) {
      setWithdrawError("회원 정보를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.");
      return;
    }
    setIsWithdrawing(true);
    // 팝업 차단 방지: 확인 클릭 직후 다른 요청 없이 재인증 팝업
    const revokeResult = await revokeSocialAccessBeforeWithdraw(authProvider, providerUserId);
    if (revokeResult !== "READY_TO_WITHDRAW") {
      setWithdrawError(WITHDRAW_STOPPED_MESSAGE[revokeResult]);
      setIsWithdrawing(false);
      return;
    }
    try {
      await withdraw();
    } catch {
      // 지워지지 않은 계정을 로그아웃만 시키면 사용자는 탈퇴된 줄 안다 — 세션을 유지하고 재시도를 안내한다
      setWithdrawError("탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.");
      setIsWithdrawing(false);
      return;
    }
    // 같은 계정 재가입이 완전 신규처럼 보이도록 회원 캐시·저장값·Firebase 세션 정리
    clearMemberSession();
    navigate("/login", { replace: true });
  };

  return (
    <SubpageLayout title="설정">
      {/* 문제풀이 섹션 — 선택지 생성 모드 토글 */}
      <section className={s0.className}>
        <SettingsSection label="문제풀이" isFirst>
          <div className="bg-surface-card border-y border-border">
            <div className="px-4 py-3.5">
              <div className="flex items-center justify-between mb-1.5">
                <span className="text-sm font-medium text-text-primary">선택지 생성 모드</span>
                <div className="flex gap-1 bg-surface rounded-lg p-0.5">
                  <button
                    type="button"
                    disabled={isModeUpdating || currentMode === "PRACTICE"}
                    onClick={() => updateMode("PRACTICE")}
                    className={`text-xs px-3 py-1 rounded-md font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                      currentMode === "PRACTICE"
                        ? "bg-brand text-on-brand"
                        : "text-text-caption hover:text-text-secondary"
                    }`}
                  >
                    연습
                  </button>
                  <button
                    type="button"
                    disabled={isModeUpdating || currentMode === "REAL"}
                    onClick={() => updateMode("REAL")}
                    className={`text-xs px-3 py-1 rounded-md font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${
                      currentMode === "REAL"
                        ? "bg-brand text-on-brand"
                        : "text-text-caption hover:text-text-secondary"
                    }`}
                  >
                    실전
                  </button>
                </div>
              </div>
              <p className="text-xs text-text-caption">
                {currentMode === "PRACTICE"
                  ? "기존 검증된 선택지 재사용 → 빠르게 시작"
                  : "매번 새 선택지 AI 생성 → 대기 있음"}
              </p>
            </div>
          </div>
        </SettingsSection>
      </section>

      {/* 이용안내 섹션 — 서브페이지 진입 row */}
      <section className={s1.className}>
        <SettingsSection label="이용안내">
          <div className="bg-surface-card border-y border-border divide-y divide-border">
            <SettingsRow
              label="건의사항"
              value={<p className="text-sm text-text-secondary">의견 남기기</p>}
              action={<ChevronRight size={16} className="text-text-caption" />}
              onClick={() => navigate("/settings/feedback")}
            />
          </div>
        </SettingsSection>
      </section>

      {/* 앱 정보 섹션 */}
      <section className={s2.className}>
        <SettingsSection label="앱 정보">
          <div className="bg-surface-card border-y border-border divide-y divide-border">
            <SettingsRow
              label="버전"
              value={
                <p className="text-sm text-text-caption">{__APP_VERSION__}</p>
              }
            />
            {/* 스토어 링크가 설정된 플랫폼만 노출 (#433) */}
            {/* Play 비공개 중엔 홈 배너와 같이 "출시 준비 중" 비활성 (#531, #658) */}
            {hasAppLinks && androidUrl && IS_GOOGLE_PLAY_PUBLIC && (
              <SettingsRow
                label="Android 앱 받기"
                value={<p className="text-sm text-text-secondary">Google Play</p>}
                action={<ExternalLink size={16} className="text-text-caption" />}
                onClick={() => window.open(androidUrl, "_blank", "noopener,noreferrer")}
              />
            )}
            {hasAppLinks && androidUrl && !IS_GOOGLE_PLAY_PUBLIC && (
              <SettingsRow
                label="Android 앱 받기"
                value={<p className="text-sm text-text-caption">출시 준비 중</p>}
              />
            )}
            {hasAppLinks && iosUrl && (
              <SettingsRow
                label="iPhone 앱 받기"
                value={<p className="text-sm text-text-secondary">App Store</p>}
                action={<ExternalLink size={16} className="text-text-caption" />}
                onClick={() => window.open(iosUrl, "_blank", "noopener,noreferrer")}
              />
            )}
          </div>
        </SettingsSection>
      </section>

      {/* 약관·사업자 정보 (#658) — 사업자 정보는 서버 값 없으면 숨김 */}
      <section className={s3.className}>
        <SettingsSection label="약관 및 사업자 정보">
          <div className="bg-surface-card border-y border-border divide-y divide-border">
            {(["TERMS_OF_SERVICE", "PRIVACY_POLICY"] as const).map((legalType) => (
              <SettingsRow
                key={legalType}
                label={LEGAL_TITLE[legalType]}
                value={null}
                action={<ChevronRight size={16} className="text-text-caption" />}
                onClick={() => setOpenedLegalType(legalType)}
              />
            ))}
            {businessInfoLines.map((line) => (
              <SettingsRow
                key={line.label}
                label={line.label}
                value={<p className="text-sm text-text-secondary break-all">{line.value}</p>}
              />
            ))}
          </div>
        </SettingsSection>
      </section>

      {/* 로그아웃 */}
      <section className={s4.className}>
        <SettingsSection label="계정 관리">
          <div className="bg-surface-card border-y border-border divide-y divide-border">
            <button
              type="button"
              disabled={isLoggingOut || isWithdrawing}
              onClick={handleLogout}
              className="flex items-center justify-between px-4 py-3.5 w-full text-left cursor-pointer hover:bg-surface active:bg-surface transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span className="text-sm font-medium text-semantic-error">
                {isLoggingOut ? "로그아웃 중..." : "로그아웃"}
              </span>
              {isLoggingOut ? (
                <span className="w-4 h-4 inline-block border-2 border-semantic-error border-t-transparent rounded-full animate-spin" />
              ) : (
                <LogOut size={16} className="text-semantic-error" />
              )}
            </button>
            {/* 회원 탈퇴 — 되돌릴 수 없으므로 확인 모달을 거친다 */}
            <button
              type="button"
              disabled={isLoggingOut || isWithdrawing}
              onClick={() => setWithdrawOpen(true)}
              className="flex items-center justify-between px-4 py-3.5 w-full text-left cursor-pointer hover:bg-surface active:bg-surface transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span className="text-sm font-medium text-text-caption">
                {isWithdrawing ? "탈퇴 처리 중..." : "회원 탈퇴"}
              </span>
              {isWithdrawing ? (
                <span className="w-4 h-4 inline-block border-2 border-text-caption border-t-transparent rounded-full animate-spin" />
              ) : (
                <ChevronRight size={16} className="text-text-caption" />
              )}
            </button>
          </div>
          {withdrawError && (
            <p role="alert" className="px-4 pt-2 text-xs text-semantic-error">
              {withdrawError}
            </p>
          )}
        </SettingsSection>
      </section>

      {/* 로고 + 카피라이트 */}
      <section className={`text-center mt-12 space-y-2 ${s5.className}`}>
        <img src={logo} alt="passQL" className="h-5 w-auto mx-auto" />
        <p className="text-xs text-text-caption">
          © 2026 passQL. All rights reserved.
        </p>
      </section>
      {openedLegalType !== null && (
        <LegalModal type={openedLegalType} onClose={() => setOpenedLegalType(null)} />
      )}
      <ConfirmModal
        isOpen={withdrawOpen}
        title="정말 탈퇴할까요?"
        description="계정과 개인정보가 즉시 삭제되고 되돌릴 수 없어요. 같은 계정으로 다시 가입하면 기존 학습 기록 없이 새로 시작해요."
        confirmLabel="탈퇴하기"
        cancelLabel="계속 이용하기"
        requiredText="탈퇴하기"
        onConfirm={handleWithdraw}
        onCancel={() => setWithdrawOpen(false)}
      />
    </SubpageLayout>
  );
}
