import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { QueryClientProvider } from "@tanstack/react-query";
import { queryClient } from "./lib/queryClient";
import { installStaleBundleReload } from "./lib/staleBundleReload";
import { clearMemberSessionAndGoToLogin } from "./lib/memberSession";
import { subscribeToAuthStorageChangesInOtherTabs } from "./stores/authStore";
import App from "./App";
import "./index.css";

installStaleBundleReload();
// 다른 탭 토큰 회전 반영, 다른 탭 로그아웃·탈퇴 > 이 탭도 정리 후 로그인 화면 (#881)
subscribeToAuthStorageChangesInOtherTabs(clearMemberSessionAndGoToLogin);

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  </StrictMode>,
);
