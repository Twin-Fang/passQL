import { useState, useEffect } from "react";
import { useNavigate, useBlocker } from "react-router-dom";

/**
 * 풀이 중 이탈 확인: 브라우저 뒤로가기(blocker)와 나가기 버튼(모달) 모두 같은 확인 모달로
 * 나가기 확정 > blocker 해제 후 홈 이동 (이중 확인 방지)
 */
export function usePracticeExitGuard(shouldBlockNavigation: boolean) {
  const navigate = useNavigate();
  // 나가기 버튼 클릭 시 이탈 확인 모달 — blocker와 독립적으로 제어
  const [exitModalOpen, setExitModalOpen] = useState(false);
  // exitConfirmed=true 시 blocker를 우회하여 홈으로 이동 — 이중 확인 방지
  const [exitConfirmed, setExitConfirmed] = useState(false);

  // useBlocker는 훅이므로 조건부 return 이전에 호출해야 함
  const blocker = useBlocker(shouldBlockNavigation && !exitConfirmed);

  // exitConfirmed 시 blocker가 비활성화된 후 홈으로 이동 — 이중 차단 방지
  useEffect(() => {
    if (exitConfirmed) {
      navigate("/");
    }
  }, [exitConfirmed, navigate]);

  return {
    isExitConfirmOpen: blocker.state === "blocked" || exitModalOpen,
    openExitConfirm: () => setExitModalOpen(true),
    cancelExit: () => {
      blocker.reset?.();
      setExitModalOpen(false);
    },
    confirmExit: () => {
      // blocker가 활성화된 경우(브라우저 뒤로가기 등) → proceed로 원래 이동 허용
      // exitModalOpen인 경우(나가기 버튼) → exitConfirmed=true로 blocker 먼저 해제 후 navigate
      if (blocker.state === "blocked") {
        blocker.proceed?.();
      } else {
        setExitConfirmed(true);
      }
      setExitModalOpen(false);
    },
  };
}
