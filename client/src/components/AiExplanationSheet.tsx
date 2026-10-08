import { X } from "lucide-react";
import MarkdownText from "./MarkdownText";

interface AiExplanationSheetProps {
  readonly isOpen: boolean;
  readonly isLoading: boolean;
  // 요청 실패 시 빈 화면 대신 안내를 보여 준다 (#354)
  readonly isError?: boolean;
  readonly text: string;
  readonly onClose: () => void;
}

function LoadingSkeleton() {
  return (
    <div className="space-y-4 py-4">
      <div className="h-4 rounded bg-border animate-pulse w-full" />
      <div className="h-4 rounded bg-border animate-pulse w-[85%]" />
      <div className="h-4 rounded bg-border animate-pulse w-[60%]" />
      <p className="text-caption text-center mt-6">AI가 분석 중입니다...</p>
    </div>
  );
}

export default function AiExplanationSheet({ isOpen, isLoading, isError = false, text, onClose }: AiExplanationSheetProps) {
  if (!isOpen) return null;

  return (
    <>
      <div className="dialog-overlay" onClick={onClose} />
      <div className="fixed inset-x-0 bottom-0 md:inset-auto md:top-1/2 md:left-1/2 md:-translate-x-1/2 md:-translate-y-1/2 md:w-[520px] md:max-h-[80vh] z-50">
        <div className="bg-surface-card rounded-t-2xl md:rounded-xl max-h-[90vh] md:max-h-[80vh] overflow-y-auto">
          <div className="md:hidden flex justify-center pt-3">
            <div className="w-10 h-1 rounded-full bg-border-muted" />
          </div>
          <div className="sticky top-0 bg-surface-card flex items-center justify-between px-4 py-3 border-b border-border z-10">
            <h2 className="text-lg font-bold text-text-primary">AI 해설</h2>
            <button
              type="button"
              className="w-8 h-8 flex items-center justify-center text-text-secondary hover:text-text-primary transition-colors"
              onClick={onClose}
            >
              <X size={16} />
            </button>
          </div>
          <div className="px-5 py-4">
            {isLoading ? <LoadingSkeleton /> : isError ? (
              <p role="alert" className="py-8 text-center text-sm text-text-secondary">
                AI 해설을 불러올 수 없어요. 잠시 후 다시 시도해 주세요.
              </p>
            ) : (
              <MarkdownText text={text} className="text-[15px] leading-relaxed text-body" />
            )}
          </div>
          {!isLoading && !isError && text && (
            <div className="px-5 pb-4 text-right">
              {/* 모델·프롬프트 버전은 서버 설정이 바뀌면 틀려지므로 고정 문구로 적지 않는다 */}
              <span className="text-caption text-xs">AI가 만든 해설이에요. 참고용으로 봐 주세요.</span>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
