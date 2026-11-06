import { useEffect } from "react";

/** 창 ESC 닫기: 떠 있는 동안 window keydown 구독 (배경 스크롤 잠금 없는 창 공용) */
export function useCloseOnEscape(onClose: () => void) {
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [onClose]);
}
