/** 선택지 body 가 JSON 배열인지 (RESULT_MATCH 결과표 보기 판별, 풀이·모의고사 해설 공통) */
export function isResultTableChoiceBody(body: string): boolean {
  try {
    return Array.isArray(JSON.parse(body));
  } catch {
    return false;
  }
}
