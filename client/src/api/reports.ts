import { apiFetch } from './client';
import type { ReportRequest, ReportStatusResponse } from '../types/api';

export async function submitReport(
  questionUuid: string,
  request: ReportRequest,
): Promise<void> {
  await apiFetch<void>(`/questions/${questionUuid}/report`, {
    method: 'POST',
    body: JSON.stringify(request),
  });
}

export async function getReportStatus(
  questionUuid: string,
  submissionUuid: string,
): Promise<ReportStatusResponse> {
  return apiFetch<ReportStatusResponse>(
    `/questions/${questionUuid}/report/status?submissionUuid=${submissionUuid}`,
  );
}
