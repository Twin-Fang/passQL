import { useLayoutEffect, type RefObject } from "react";

export type CssVariables = Readonly<Record<`--${string}`, string>>;

/**
 * 런타임 값(진행률·위치·이동량) > 요소의 CSS 변수 주입
 * JSX style 속성 금지 규칙의 유일한 통로 (클래스에서 var(--이름) 으로 사용, #462)
 */
export function useCssVariables(elementRef: RefObject<HTMLElement | null>, cssVariables: CssVariables): void {
  // 매 렌더 적용 (조건부로 다시 마운트된 요소도 같은 값을 받도록)
  useLayoutEffect(() => {
    const element = elementRef.current;
    if (!element) return;
    for (const [variableName, variableValue] of Object.entries(cssVariables)) {
      element.style.setProperty(variableName, variableValue);
    }
  });
}
