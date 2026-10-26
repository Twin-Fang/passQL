import type { BusinessInfo } from "../types/api";

export type BusinessInfoLine = {
  readonly label: string;
  readonly value: string;
};

/**
 * 사업자 정보 > 표시 줄 목록 (#658)
 * 상호 없음·구버전 서버(필드 없음) > 빈 목록, 그 외 빈 값 줄 제외
 */
export function toBusinessInfoLines(businessInfo: BusinessInfo | null | undefined): readonly BusinessInfoLine[] {
  if (!businessInfo?.companyName) return [];
  const candidateLines: readonly (readonly [string, string | null])[] = [
    ["상호", businessInfo.companyName],
    ["대표자", businessInfo.representativeName],
    ["사업자등록번호", businessInfo.registrationNumber],
    ["통신판매업 신고번호", businessInfo.mailOrderSalesNumber],
    ["문의", businessInfo.contactEmail],
  ];
  return candidateLines
    .filter((line): line is readonly [string, string] => Boolean(line[1]?.trim()))
    .map(([label, value]) => ({ label, value: value.trim() }));
}
