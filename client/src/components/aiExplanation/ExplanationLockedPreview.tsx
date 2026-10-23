import LockedPreview from "../pro/LockedPreview";
import { ExplanationLockedSample } from "../pro/lockedPreviewSamples";
import { LOCKED_PREVIEW_CAPTIONS } from "../../constants/proAccessCopy";

/** 해설 묶음 잠금 자리 (판정 아래·판정 없을 때 공용, #578) */
export default function ExplanationLockedPreview() {
  return <LockedPreview preview={<ExplanationLockedSample />} caption={LOCKED_PREVIEW_CAPTIONS.explanation} />;
}
