import { RefreshCw, Wrench } from "lucide-react";

interface MaintenanceScreenProps {
  readonly message: string;
  readonly isRechecking: boolean;
  readonly onRecheckPressed: () => void;
}

/** 점검 화면: 관리자 문구 + "다시 확인" (앱 전체 대체) (#464) */
export default function MaintenanceScreen({
  message,
  isRechecking,
  onRecheckPressed,
}: MaintenanceScreenProps) {
  return (
    <main className="min-h-screen bg-surface flex items-center justify-center px-4">
      <section
        aria-labelledby="maintenance-title"
        className="w-full max-w-90 bg-surface-card border border-border rounded-2xl py-10 px-6 flex flex-col items-center text-center gap-4"
      >
        <div className="w-14 h-14 rounded-full bg-brand-light flex items-center justify-center">
          <Wrench size={26} className="text-brand" />
        </div>
        <div className="space-y-1.5">
          <h1 id="maintenance-title" className="text-h2 text-text-primary">
            서비스 점검 중이에요
          </h1>
          {/* 관리자 문구 줄바꿈 유지 */}
          <p className="text-sm text-text-secondary leading-relaxed whitespace-pre-line">
            {message}
          </p>
        </div>
        <button
          type="button"
          className="btn btn-primary w-full mt-2"
          onClick={onRecheckPressed}
          disabled={isRechecking}
        >
          {isRechecking
            ? <span className="loading loading-spinner loading-sm" />
            : <RefreshCw size={16} />}
          다시 확인
        </button>
      </section>
    </main>
  );
}
