import { useEffect, type ReactNode } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { APP_CONFIG_QUERY_KEY, useAppConfig } from "../hooks/useAppConfig";
import { useMaintenanceStore } from "../stores/maintenanceStore";
import MaintenanceScreen from "./MaintenanceScreen";

// 관리자 문구가 비었을 때의 점검 문구 (앱 AppLaunchDecision.defaultMaintenanceMessage 와 같은 문구)
export const DEFAULT_MAINTENANCE_MESSAGE =
  "더 나은 서비스를 위해 점검하고 있어요.\n잠시 후 다시 이용해 주세요.";

/**
 * 점검 차단 게이트: 시작 설정 점검 상태 또는 API 503 감지 > 점검 화면으로 전체 대체 (#464)
 * 설정 조회 중·실패 시에는 막지 않음
 */
export default function MaintenanceGate({ children }: { readonly children: ReactNode }) {
  const queryClient = useQueryClient();
  const appConfigQuery = useAppConfig();
  const { refetch: refetchAppConfig } = appConfigQuery;
  const isMaintenanceDetectedByApi = useMaintenanceStore((state) => state.isMaintenanceDetectedByApi);
  const clearMaintenanceDetectedByApi = useMaintenanceStore((state) => state.clearMaintenanceDetectedByApi);

  // 사용 도중 503 감지 > 관리자 문구 받으러 설정 재조회
  useEffect(() => {
    if (isMaintenanceDetectedByApi) void refetchAppConfig();
  }, [isMaintenanceDetectedByApi, refetchAppConfig]);

  const maintenance = appConfigQuery.data?.maintenance;
  const isUnderMaintenance = maintenance?.isUnderMaintenance === true || isMaintenanceDetectedByApi;
  if (!isUnderMaintenance) return <>{children}</>;

  /** 다시 확인: 설정 재조회 > 해제됐으면 감지 기록 초기화 + 503 받은 데이터 재조회 */
  const onRecheckPressed = async () => {
    const recheckResult = await refetchAppConfig();
    const isMaintenanceLifted = recheckResult.data?.maintenance.isUnderMaintenance === false;
    if (!isMaintenanceLifted) return;
    clearMaintenanceDetectedByApi();
    void queryClient.invalidateQueries({
      predicate: (query) => query.queryKey[0] !== APP_CONFIG_QUERY_KEY[0],
    });
  };

  return (
    <MaintenanceScreen
      message={maintenance?.message?.trim() || DEFAULT_MAINTENANCE_MESSAGE}
      isRechecking={appConfigQuery.isFetching}
      onRecheckPressed={() => void onRecheckPressed()}
    />
  );
}
