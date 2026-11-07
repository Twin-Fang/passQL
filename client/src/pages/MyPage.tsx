import { useNavigate } from "react-router-dom";
import { Settings, ChevronRight } from "lucide-react";
import { useAuthStore } from "../stores/authStore";
import { useStagger } from "../hooks/useStagger";
import { useMember } from "../hooks/useMember";
import { useWrongQuestions } from "../hooks/useWrongQuestions";
import { formatDottedDate, LOGIN_PROVIDER_LABEL } from "../lib/loginProviderPresentation";
import PlanChip from "../components/pro/PlanChip";
import ProfileAvatar from "../components/ProfileAvatar";
import LoginProviderIcon from "../components/LoginProviderIcon";
import WrongQuestionListState from "../components/wrongNotes/WrongQuestionListState";
import { WRONG_NOTES_PATH, WRONG_NOTES_PREVIEW_COUNT } from "../constants/wrongNotes";

export default function MyPage() {
  const navigate = useNavigate();
  const uuid = useAuthStore((s) => s.memberUuid ?? "");
  const nickname = useAuthStore((s) => s.nickname ?? "");
  const { data: memberData } = useMember();

  const stagger = useStagger();
  const s0 = stagger(0);
  const s1 = stagger(1);
  const s2 = stagger(2);

  // 오답 미리보기 (프로 전용, 무료는 목록 상태 컴포넌트가 잠금 미리보기)
  const wrongQuestions = useWrongQuestions(WRONG_NOTES_PREVIEW_COUNT);

  const displayName = nickname || uuid.slice(0, 8);
  const authProvider = memberData?.authProvider;
  const joinedAt = memberData?.createdAt;
  // 예: [카카오 아이콘] 로그인 · 2026.10.16 가입 (가입일 모르면 로그인만)
  const accountSummary = [authProvider ? "로그인" : null, joinedAt ? `${formatDottedDate(joinedAt)} 가입` : null]
    .filter(Boolean)
    .join(" · ");

  const totalWrongCount = wrongQuestions.data?.totalCount ?? 0;

  return (
    <div className="py-6 space-y-6">
      {/* 헤더 */}
      <section className={`flex items-center justify-between ${s0.className}`}>
        <h1 className="text-h1">마이페이지</h1>
        <button
          type="button"
          onClick={() => navigate("/settings")}
          className="w-9 h-9 bg-surface-card border border-border rounded-tile flex items-center justify-center hover:bg-surface transition-colors"
          aria-label="설정"
        >
          <Settings size={18} className="text-text-caption" />
        </button>
      </section>

      {/* 프로필 카드 (#908): 소셜 프로필 사진 + 닉네임 + 로그인 방법 아이콘·가입일, 닉네임 변경은 `관리`(설정 내 계정)에서만 */}
      <section className={`bg-surface-card border border-border rounded-2xl p-5 flex items-center gap-4 ${s1.className}`}>
        <ProfileAvatar fallbackName={displayName} imageUrl={memberData?.profileImageUrl} />
        <div className="flex-1 min-w-0">
          {/* 닉네임 + 등급 칩 (결제 꺼짐이면 칩 없음, #578) */}
          <div className="flex items-center gap-2 min-w-0">
            <p className="text-lg font-bold text-text-primary truncate">{displayName}</p>
            <PlanChip />
          </div>
          {accountSummary && (
            <p className="flex items-center gap-1 text-xs text-text-secondary mt-0.5 min-w-0">
              {authProvider && <LoginProviderIcon provider={authProvider} isSmall isLabelHidden />}
              <span className="truncate">
                {authProvider && <span className="sr-only">{LOGIN_PROVIDER_LABEL[authProvider]} </span>}
                {accountSummary}
              </span>
            </p>
          )}
        </div>
        <button
          type="button"
          onClick={() => navigate("/settings")}
          className="flex items-center gap-0.5 min-h-11 px-1 text-sm font-semibold text-brand shrink-0"
          aria-label="계정 관리"
        >
          관리
          <ChevronRight size={14} aria-hidden="true" />
        </button>
      </section>

      {/* 오답 노트 섹션 */}
      <section className={s2.className}>
        <div className="bg-surface-card border border-border rounded-2xl overflow-hidden">
          {/* 오답 노트 헤더 */}
          <div className="flex items-center justify-between px-4 py-3.5 border-b border-border">
            <div className="flex items-center gap-2">
              <span className="text-subheadline font-semibold text-text-primary">오답 노트</span>
              {totalWrongCount > 0 && (
                <span className="text-caption2 font-semibold bg-semantic-error-light text-semantic-error px-2 py-0.5 rounded-full">
                  {totalWrongCount}개
                </span>
              )}
            </div>
            {totalWrongCount > WRONG_NOTES_PREVIEW_COUNT && (
              <button
                type="button"
                onClick={() => navigate(WRONG_NOTES_PATH)}
                className="flex items-center gap-0.5 text-xs text-brand font-medium"
              >
                전체보기
                <ChevronRight size={12} />
              </button>
            )}
          </div>

          {/* 오답 목록 (로딩·잠금·오류·빈 상태 포함) */}
          <WrongQuestionListState
            isLoading={wrongQuestions.isLoading}
            error={wrongQuestions.error}
            items={wrongQuestions.data?.items ?? []}
            skeletonRowCount={3}
            isInsideCard
            onRetry={() => void wrongQuestions.refetch()}
          />
        </div>
      </section>
    </div>
  );
}
