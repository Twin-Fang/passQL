import { Link, isRouteErrorResponse, useRouteError } from "react-router-dom";
import { AlertCircle, SearchX } from "lucide-react";

/**
 * 라우터 수준 오류 화면 (#397).
 * 없는 경로(`*`)와 렌더 중 예외를 React Router 기본 개발자 화면 대신 서비스 톤으로 보여준다.
 */
export default function RouteError({ notFound = false }: { readonly notFound?: boolean }) {
  // `*` 라우트로 렌더될 때는 라우터 에러 컨텍스트가 없다
  const error = useRouteError();
  const isNotFound = notFound || (isRouteErrorResponse(error) && error.status === 404);

  return (
    <div className="min-h-dvh grid place-items-center bg-surface px-4">
      <div className="bg-surface-card border border-border rounded-2xl py-10 px-6 w-full max-w-sm flex flex-col items-center text-center gap-4">
        <div className="w-14 h-14 rounded-full bg-surface flex items-center justify-center">
          {isNotFound
            ? <SearchX size={28} className="text-text-caption" />
            : <AlertCircle size={28} className="text-text-caption" />}
        </div>
        <div className="space-y-1.5">
          <p className="text-base font-semibold text-text-primary">
            {isNotFound ? "페이지를 찾을 수 없어요" : "화면을 표시하지 못했어요"}
          </p>
          <p className="text-sm text-text-secondary leading-relaxed">
            {isNotFound
              ? "주소가 바뀌었거나 없는 페이지예요."
              : "잠시 후 다시 시도해보세요. 문제가 반복되면 페이지를 새로고침해 주세요."}
          </p>
        </div>
        <div className="flex gap-2 mt-2">
          {!isNotFound && (
            <button type="button" className="btn-compact" onClick={() => window.location.reload()}>
              새로고침
            </button>
          )}
          <Link to="/" className="btn-compact">
            홈으로
          </Link>
        </div>
      </div>
    </div>
  );
}
