import { useNavigate } from "react-router-dom";
import { Settings, Pencil, ChevronRight } from "lucide-react";
import { useState } from "react";
import { useAuthStore } from "../stores/authStore";
import { useStagger } from "../hooks/useStagger";
import { useMember } from "../hooks/useMember";
import { useWrongQuestions } from "../hooks/useWrongQuestions";
import { isNicknameCooldown, formatNicknameCooldownMessage } from "../lib/nicknameCooldown";
import NicknameChangeModal from "../components/NicknameChangeModal";
import PlanChip from "../components/pro/PlanChip";
import WrongQuestionListState from "../components/wrongNotes/WrongQuestionListState";
import { WRONG_NOTES_PATH, WRONG_NOTES_PREVIEW_COUNT } from "../constants/wrongNotes";

export default function MyPage() {
  const navigate = useNavigate();
  const uuid = useAuthStore((s) => s.memberUuid ?? "");
  const nickname = useAuthStore((s) => s.nickname ?? "");
  const { data: memberData } = useMember();
  const [isNicknameModalOpen, setIsNicknameModalOpen] = useState(false);
  const [toastMsg, setToastMsg] = useState<string | null>(null);

  const stagger = useStagger();
  const s0 = stagger(0);
  const s1 = stagger(1);
  const s2 = stagger(2);

  // 오답 미리보기 (프로 전용, 무료는 목록 상태 컴포넌트가 잠금 미리보기)
  const wrongQuestions = useWrongQuestions(WRONG_NOTES_PREVIEW_COUNT);

  const showToast = (msg: string) => {
    setToastMsg(msg);
    setTimeout(() => setToastMsg(null), 2000);
  };

  const handleNicknameEditClick = () => {
    const changedAt = memberData?.nicknameChangedAt ?? null;
    if (isNicknameCooldown(changedAt)) {
      showToast(formatNicknameCooldownMessage(changedAt!));
      return;
    }
    setIsNicknameModalOpen(true);
  };

  // 닉네임 첫 글자로 아바타 이니셜 생성
  const avatarLetter = (nickname || uuid.slice(0, 1)).slice(0, 1).toUpperCase();

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

      {/* 프로필 카드 */}
      <section className={`bg-surface-card border border-border rounded-2xl p-5 flex items-center gap-4 ${s1.className}`}>
        {/* 아바타 */}
        <div className="w-14 h-14 rounded-tile-large bg-brand flex items-center justify-center shrink-0">
          <span className="text-2xl font-bold text-on-brand">{avatarLetter}</span>
        </div>
        <div className="flex-1 min-w-0">
          {/* 닉네임 + 등급 칩 (결제 꺼짐이면 칩 없음, #578) */}
          <div className="flex items-center gap-2 min-w-0">
            <p className="text-lg font-bold text-text-primary truncate">
              {nickname || uuid.slice(0, 8)}
            </p>
            <PlanChip />
          </div>
          <p className="text-xs text-text-caption mt-0.5">
            마지막 학습 · {memberData?.nicknameChangedAt ? "최근" : "기록 없음"}
          </p>
        </div>
        {/* 닉네임 수정 버튼 */}
        <button
          type="button"
          onClick={handleNicknameEditClick}
          className="w-8 h-8 bg-surface border border-border rounded-lg flex items-center justify-center transition-colors hover:text-brand text-text-caption"
          aria-label="닉네임 변경"
        >
          <Pencil size={14} />
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

      {/* Toast */}
      {toastMsg && (
        <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 pointer-events-none">
          <div className="bg-brand text-on-brand text-sm font-medium px-4 py-2.5 rounded-lg shadow-md whitespace-nowrap">
            {toastMsg}
          </div>
        </div>
      )}

      <NicknameChangeModal
        isOpen={isNicknameModalOpen}
        currentNickname={nickname || ""}
        onClose={() => setIsNicknameModalOpen(false)}
        onSuccess={() => showToast("닉네임이 변경됐어요")}
      />
    </div>
  );
}
