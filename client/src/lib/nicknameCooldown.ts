/**
 * 닉네임 변경 대기 판정·안내 (#881): 서버 nicknameChangeAvailableAt(변경 + 3일) 원본, 웹은 표시만
 * 서버 값은 KST LocalDateTime(오프셋 없음) > 브라우저 현지 시각으로 해석
 */

// 대기 안내 시각 표시 (예: 11월 10일 오후 3:20)
const AVAILABLE_AT_FORMATTER = new Intl.DateTimeFormat("ko-KR", {
  month: "long",
  day: "numeric",
  hour: "numeric",
  minute: "2-digit",
});

/** 아직 대기 중인지 (변경 이력 없음·시각 지남이면 false) */
export function isNicknameChangeWaiting(nicknameChangeAvailableAt: string | null | undefined): boolean {
  if (!nicknameChangeAvailableAt) return false;
  return Date.now() < new Date(nicknameChangeAvailableAt).getTime();
}

/** 변경 가능 시각 > 안내 문구 (예: "11월 10일 오후 3:20부터 바꿀 수 있어요") */
export function formatNicknameChangeWaitingMessage(nicknameChangeAvailableAt: string): string {
  return `${AVAILABLE_AT_FORMATTER.format(new Date(nicknameChangeAvailableAt))}부터 바꿀 수 있어요`;
}
