import { useState, useCallback, useRef, useEffect } from "react";

// 신고 완료 토스트 표시 시간 (ms)
const REPORT_TOAST_VISIBLE_MILLISECONDS = 2500;

/**
 * 제출 신고: 모달 열림, 신고 완료 submissionUuid 목록(중복 신고 방지), 완료 토스트 자동 숨김
 */
export function useSubmissionReport() {
  // 신고 모달 표시 여부
  const [isReportModalOpen, setIsReportModalOpen] = useState(false);
  // 신고 완료된 submissionUuid 목록 — 중복 신고 방지
  const [reportedSubmissions, setReportedSubmissions] = useState<Set<string>>(new Set());
  // 신고 완료 토스트 표시 여부
  const [isReportToastVisible, setIsReportToastVisible] = useState(false);
  const toastTimerIdRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // 토스트 타이머 언마운트 클린업
  useEffect(() => {
    return () => {
      if (toastTimerIdRef.current !== null) clearTimeout(toastTimerIdRef.current);
    };
  }, []);

  // 신고 성공: 목록 추가 > 모달 닫기 > 토스트 (2.5초 후 자동 숨김, 이전 타이머 교체)
  const markSubmissionReported = useCallback((submissionUuid: string) => {
    setReportedSubmissions((prev) => new Set([...prev, submissionUuid]));
    setIsReportModalOpen(false);
    setIsReportToastVisible(true);
    if (toastTimerIdRef.current !== null) clearTimeout(toastTimerIdRef.current);
    toastTimerIdRef.current = setTimeout(() => setIsReportToastVisible(false), REPORT_TOAST_VISIBLE_MILLISECONDS);
  }, []);

  return {
    isReportModalOpen,
    isReportToastVisible,
    openReportModal: () => setIsReportModalOpen(true),
    closeReportModal: () => setIsReportModalOpen(false),
    isSubmissionReported: (submissionUuid: string) => reportedSubmissions.has(submissionUuid),
    markSubmissionReported,
  };
}
