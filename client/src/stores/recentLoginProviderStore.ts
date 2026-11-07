import { create } from "zustand";
import { createJSONStorage, persist } from "zustand/middleware";
import type { AuthProvider } from "../types/api";

// 브라우저 저장 키 (이 기기 전용 편의: 로그인 화면 "최근 로그인" 표시, #908)
const RECENT_LOGIN_PROVIDER_STORAGE_KEY = "passql.login.recentProvider";

interface RecentLoginProviderState {
  readonly recentLoginProvider: AuthProvider | null;
  rememberRecentLoginProvider: (provider: AuthProvider) => void;
  clearRecentLoginProvider: () => void;
}

/**
 * 최근 로그인 제공자: 로그인 성공 때 기록 > 로그인 화면 배지
 * 계정이 아니라 기기 기록 > 로그아웃해도 유지, 탈퇴 때만 삭제 (막혀 있으면 메모리로만 동작)
 */
export const useRecentLoginProviderStore = create<RecentLoginProviderState>()(
  persist(
    (set) => ({
      recentLoginProvider: null,
      rememberRecentLoginProvider: (provider) => set({ recentLoginProvider: provider }),
      clearRecentLoginProvider: () => set({ recentLoginProvider: null }),
    }),
    {
      name: RECENT_LOGIN_PROVIDER_STORAGE_KEY,
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ recentLoginProvider: state.recentLoginProvider }),
    },
  ),
);
