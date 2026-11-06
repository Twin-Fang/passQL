import { describe, expect, it } from "vitest";
import {
  findCrossedAnnouncementMinute,
  formatRemainingClock,
  toCountdownTone,
  toRemainingSecondsAt,
  toRemainingTimeSpeech,
} from "./mockExamCountdown";

// 모의고사 남은 시간 핵심 판정 고정 (#866): 단조 시계 경과, 색 단계 경계, 낭독 시점
describe("mockExamCountdown", () => {
  it("서버 남은 초에서 단조 시계 경과(초 내림)만큼 줄이고 0 아래로 내려가지 않음", () => {
    expect(toRemainingSecondsAt(5400, 1000, 1000)).toBe(5400);
    expect(toRemainingSecondsAt(5400, 1000, 2999)).toBe(5399);
    expect(toRemainingSecondsAt(10, 0, 60_000)).toBe(0);
    // 단조 시계가 뒤로 가는 값이 와도 늘지 않음
    expect(toRemainingSecondsAt(100, 5000, 1000)).toBe(100);
  });

  it("시계 문구는 분이 60을 넘어도 분:초", () => {
    expect(formatRemainingClock(5400)).toBe("90:00");
    expect(formatRemainingClock(59)).toBe("00:59");
    expect(formatRemainingClock(-3)).toBe("00:00");
  });

  it("낭독 문구는 분 올림, 1분 미만은 초", () => {
    expect(toRemainingTimeSpeech(719)).toBe("남은 시간 12분");
    expect(toRemainingTimeSpeech(45)).toBe("남은 시간 45초");
  });

  it("색 단계 경계: 10분 이하 warning, 5분 이하 danger", () => {
    expect(toCountdownTone(601)).toBe("normal");
    expect(toCountdownTone(600)).toBe("warning");
    expect(toCountdownTone(300)).toBe("danger");
  });

  it("낭독 시점은 경계를 지날 때 한 번, 여러 개를 건너뛰면 가장 작은 시점", () => {
    expect(findCrossedAnnouncementMinute(1801, 1800)).toBe(30);
    expect(findCrossedAnnouncementMinute(1800, 1799)).toBeNull();
    expect(findCrossedAnnouncementMinute(1900, 250)).toBe(5);
  });
});
