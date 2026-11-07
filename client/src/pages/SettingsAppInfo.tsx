import SettingsRow from "../components/SettingsRow";
import SettingsSection from "../components/SettingsSection";
import SubpageLayout from "../components/SubpageLayout";
import { useBusinessInfoLines } from "../hooks/useBusinessInfoLines";

/** 앱 정보 서브페이지 (#658): 버전 > 사업자 정보(값 있을 때) */
export default function SettingsAppInfo() {
  const businessInfoLines = useBusinessInfoLines();
  return (
    <SubpageLayout title="앱 정보">
      <SettingsSection label="앱">
        <div className="bg-surface-card border-y border-border divide-y divide-border">
          <SettingsRow label="버전" value={<p className="text-sm text-text-caption">{__APP_VERSION__}</p>} />
        </div>
      </SettingsSection>
      {businessInfoLines.length > 0 && (
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
      )}
    </SubpageLayout>
  );
}
