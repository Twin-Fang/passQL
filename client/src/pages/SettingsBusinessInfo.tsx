import SettingsRow from "../components/SettingsRow";
import SettingsSection from "../components/SettingsSection";
import SubpageLayout from "../components/SubpageLayout";
import { useBusinessInfoLines } from "../hooks/useBusinessInfoLines";

/** 사업자 정보 서브페이지 (#658): 설정 > 약관 및 사업자 정보 > 사업자 정보 */
export default function SettingsBusinessInfo() {
  const businessInfoLines = useBusinessInfoLines();
  return (
    <SubpageLayout title="사업자 정보">
      <SettingsSection label="사업자 정보">
        <div className="bg-surface-card border-y border-border divide-y divide-border">
          {businessInfoLines.map((line) => (
            <SettingsRow
              key={line.label}
              label={line.label}
              value={<p className="text-sm text-text-secondary break-all">{line.value}</p>}
            />
          ))}
        </div>
      </SettingsSection>
    </SubpageLayout>
  );
}
