import { useState, useEffect, useRef } from "react";

// 맞힌 개수(0~10) > 점수 글자색 (0~3 오류, 4~6 경고, 7~8 브랜드, 9~10 성공)
const COLOR_CLASS_SCALE = [
  "text-semantic-error", "text-semantic-error", "text-semantic-error", "text-semantic-error",
  "text-semantic-warning", "text-semantic-warning", "text-semantic-warning",
  "text-brand", "text-brand",
  "text-semantic-success", "text-semantic-success",
] as const;

interface ScoreCountUpProps {
  readonly target: number;
  readonly total: number;
  readonly onComplete?: () => void;
}

export default function ScoreCountUp({ target, total, onComplete }: ScoreCountUpProps) {
  const [count, setCount] = useState(0);
  const [animating, setAnimating] = useState(false);
  const onCompleteRef = useRef(onComplete);
  onCompleteRef.current = onComplete;

  useEffect(() => {
    if (target <= 0) {
      setTimeout(() => onCompleteRef.current?.(), 200);
      return;
    }
    let step = 0;
    const tick = () => {
      step++;
      setCount(step);
      setAnimating(true);
      setTimeout(() => setAnimating(false), 200);
      if (step < target) {
        setTimeout(tick, 60 + step * 30);
      } else {
        setTimeout(() => onCompleteRef.current?.(), 200);
      }
    };
    const timer = setTimeout(tick, 200);
    return () => clearTimeout(timer);
  }, [target]);

  const colorClass = COLOR_CLASS_SCALE[count] ?? COLOR_CLASS_SCALE[0];

  return (
    // 한 칸 오를 때마다 튕기듯 1.3배 확대 후 복귀
    <div
      className={`text-[96px] font-bold leading-none transition-[scale,color] duration-200 ease-[cubic-bezier(0.34,1.56,0.64,1)] ${colorClass} ${
        animating ? "scale-130" : "scale-100"
      }`}
    >
      {count} <span className="text-4xl font-normal text-text-caption">/ {total}</span>
    </div>
  );
}
