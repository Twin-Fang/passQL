/**
 * 관리자 목록 순서 변경 공통: 표(행마다 data-order-row, data-code)에서 한 칸 이동한 전체 코드 순서 > 저장 콜백
 * 토픽·서브토픽·개념 태그 화면에서 사용
 */
function moveOrderRow(code, step, containerId, saveOrder) {
    const orderedCodes = Array.from(document.querySelectorAll(`#${containerId} [data-order-row]`))
        .map(row => row.dataset.code);
    const fromIndex = orderedCodes.indexOf(code);
    const toIndex = fromIndex + step;
    // 맨 위·맨 아래는 이동하지 않음
    if (fromIndex < 0 || toIndex < 0 || toIndex >= orderedCodes.length) return;
    orderedCodes.splice(toIndex, 0, orderedCodes.splice(fromIndex, 1)[0]);
    saveOrder(orderedCodes);
}
