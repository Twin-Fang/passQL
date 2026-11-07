import { useState } from "react";
import { ChevronRight } from "lucide-react";
import { useAuthStore } from "../stores/authStore";
import { useMember } from "../hooks/useMember";
import { isNicknameChangeWaiting, formatNicknameChangeWaitingMessage } from "../lib/nicknameCooldown";
import { formatDottedDate, loginAccountLabelOf, LOGIN_PROVIDER_LABEL } from "../lib/loginProviderPresentation";
import NicknameChangeModal from "./NicknameChangeModal";
import LoginProviderIcon from "./LoginProviderIcon";
import SettingsSection from "./SettingsSection";
import SettingsRow from "./SettingsRow";

// 안내 토스트 표시 시간 (ms)
const TOAST_VISIBLE_MILLISECONDS = 2000;

/**
 * 설정 `내 계정` 묶음 (#908, 앱 계정 화면과 같은 행): 닉네임(눌러서 변경), 로그인 방법(아이콘 + 이메일), 가입일, 회원 번호
 * 닉네임 변경 진입점은 여기 하나 (마이페이지 프로필 카드는 이 화면으로 이동만)
 */
export default function AccountInfoSection({ className }: { readonly className?: string }) {
  const nickname = useAuthStore((s) => s.nickname ?? "");
  const { data: memberData } = useMember();
  const [isNicknameModalOpen, setIsNicknameModalOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (message: string) => {
    setToastMessage(message);
    setTimeout(() => setToastMessage(null), TOAST_VISIBLE_MILLISECONDS);
  };

  const handleNicknameRowClick = () => {
    // 대기 시각은 서버 값 (서버 거절 기준과 같음)
    const nicknameChangeAvailableAt = memberData?.nicknameChangeAvailableAt ?? null;
    if (nicknameChangeAvailableAt && isNicknameChangeWaiting(nicknameChangeAvailableAt)) {
      showToast(formatNicknameChangeWaitingMessage(nicknameChangeAvailableAt));
      return;
    }
    setIsNicknameModalOpen(true);
  };

  const authProvider = memberData?.authProvider;
  const accountLabel = authProvider ? loginAccountLabelOf(authProvider, memberData?.email) : null;

  return (
    <section className={className}>
      <SettingsSection label="내 계정" isFirst>
        <div className="bg-surface-card border-y border-border divide-y divide-border">
          <SettingsRow
            label="닉네임"
            value={<p className="text-sm text-text-secondary max-w-48 truncate">{nickname}</p>}
            action={<ChevronRight size={16} className="text-text-caption" />}
            onClick={handleNicknameRowClick}
          />
          {authProvider && accountLabel && (
            <SettingsRow
              label="로그인 방법"
              value={
                <span className="flex items-center gap-2 max-w-56">
                  {/* 이름으로 대체 표시면 아이콘 이름은 읽지 않음 (같은 말 두 번) */}
                  <LoginProviderIcon
                    provider={authProvider}
                    isLabelHidden={accountLabel === LOGIN_PROVIDER_LABEL[authProvider]}
                  />
                  <span className="text-sm text-text-secondary truncate">{accountLabel}</span>
                </span>
              }
            />
          )}
          {memberData?.createdAt && (
            <SettingsRow
              label="가입일"
              value={<p className="text-sm text-text-secondary">{formatDottedDate(memberData.createdAt)}</p>}
            />
          )}
          {memberData?.memberCode && (
            <SettingsRow
              label="회원 번호"
              value={<p className="text-sm text-text-secondary select-all">{memberData.memberCode}</p>}
            />
          )}
        </div>
        <p className="px-4 pt-2 text-xs text-text-caption">
          소셜 로그인이라 비밀번호는 없어요. 문의할 때 회원 번호를 알려 주세요
        </p>
      </SettingsSection>

      {toastMessage && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 pointer-events-none" role="status">
          <div className="bg-brand text-on-brand text-sm font-medium px-4 py-2.5 rounded-lg shadow-md whitespace-nowrap">
            {toastMessage}
          </div>
        </div>
      )}

      <NicknameChangeModal
        isOpen={isNicknameModalOpen}
        currentNickname={nickname}
        onClose={() => setIsNicknameModalOpen(false)}
        onSuccess={() => showToast("닉네임이 변경됐어요")}
      />
    </section>
  );
}
