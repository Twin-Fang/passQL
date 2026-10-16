import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { shouldRetry } from "./api/retry";
import App from "./App";
import "./index.css";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,
      // 화면 이탈 후 캐시 보관 30분 (기본 5분이면 staleTime 10~30분 쿼리가 복귀 시 재요청), AI 코멘트는 쿼리별 더 길게
      gcTime: 1000 * 60 * 30,
      retry: shouldRetry,
      refetchOnWindowFocus: false,
    },
  },
});

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  </StrictMode>,
);
