import { create } from "zustand";

/**
 * 점검 감지 상태: API 503 SERVICE_UNDER_MAINTENANCE 수신 여부 (#464)
 * 시작 시 설정 조회 결과와 합쳐 MaintenanceGate 가 점검 화면 전환 판단
 */
interface MaintenanceState {
  readonly isMaintenanceDetectedByApi: boolean;
  readonly markMaintenanceDetectedByApi: () => void;
  readonly clearMaintenanceDetectedByApi: () => void;
}

export const useMaintenanceStore = create<MaintenanceState>()((set) => ({
  isMaintenanceDetectedByApi: false,
  markMaintenanceDetectedByApi: () => set({ isMaintenanceDetectedByApi: true }),
  clearMaintenanceDetectedByApi: () => set({ isMaintenanceDetectedByApi: false }),
}));
