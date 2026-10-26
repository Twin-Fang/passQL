import { useBusinessInfoLines } from "../hooks/useBusinessInfoLines";

type BusinessInfoNoticeProps = {
  readonly className?: string;
};

/**
 * 사이드바 푸터 사업자 정보 표기 (#658): 원본은 서버 app-config businessInfo
 * 설정 조회 실패·상호 없음 > 렌더하지 않음
 */
export default function BusinessInfoNotice({ className = "" }: BusinessInfoNoticeProps) {
  const businessInfoLines = useBusinessInfoLines();
  if (businessInfoLines.length === 0) return null;

  return (
    <dl aria-label="사업자 정보" className={`text-micro text-text-caption leading-relaxed ${className}`}>
      {businessInfoLines.map((line) => (
        <div key={line.label}>
          <dt className="inline">{line.label} </dt>
          <dd className="inline break-all">{line.value}</dd>
        </div>
      ))}
    </dl>
  );
}
