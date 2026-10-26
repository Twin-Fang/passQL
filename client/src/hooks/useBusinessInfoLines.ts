import { useAppConfig } from "./useAppConfig";
import { toBusinessInfoLines, type BusinessInfoLine } from "../lib/businessInfoPresentation";

/**
 * 사업자 정보 표시 줄 (#658): app-config businessInfo > 줄 목록
 * 조회 실패·구버전 서버·상호 없음 > 빈 목록
 */
export function useBusinessInfoLines(): readonly BusinessInfoLine[] {
  const { data: appConfig } = useAppConfig();
  return toBusinessInfoLines(appConfig?.businessInfo);
}
