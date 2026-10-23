import { useState } from "react";
import AppPassGuideModal from "./AppPassGuideModal";
import { UNLOCK_IN_APP_LABEL } from "../../constants/proAccessCopy";

/** 잠금 자리 공통 알약 버튼: 누르면 앱 이용권 안내 창 (잠금 미리보기·사유 화면 공용) */
export default function UnlockInAppButton() {
  const [isGuideOpen, setIsGuideOpen] = useState(false);
  return (
    <>
      <button type="button" className="btn btn-primary btn-sm rounded-full" onClick={() => setIsGuideOpen(true)}>
        {UNLOCK_IN_APP_LABEL}
      </button>
      {isGuideOpen && <AppPassGuideModal onClose={() => setIsGuideOpen(false)} />}
    </>
  );
}
