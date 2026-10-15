import { apiFetch } from "./client";
import type { ExamScheduleResponse } from "../types/api";

export function fetchExamSchedules(certType?: string): Promise<ExamScheduleResponse[]> {
  const query = new URLSearchParams();
  if (certType) query.set("certType", certType);
  const queryString = query.toString();
  return apiFetch(`/exam-schedules${queryString ? `?${queryString}` : ""}`);
}

export function fetchSelectedSchedule(): Promise<ExamScheduleResponse | null> {
  return apiFetch("/exam-schedules/selected");
}
