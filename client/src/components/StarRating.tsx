import { memo } from "react";
import { Star } from "lucide-react";
import { MAX_QUESTION_DIFFICULTY } from "../lib/questionDifficulty";

interface StarRatingProps {
  readonly level: number;
}

export const StarRating = memo(function StarRating({ level }: StarRatingProps) {
  return (
    <span className="flex gap-0.5">
      {Array.from({ length: MAX_QUESTION_DIFFICULTY }, (_, i) => (
        <Star
          key={i}
          size={14}
          className={i < level ? "fill-semantic-warning text-semantic-warning" : "text-border"}
        />
      ))}
    </span>
  );
});
