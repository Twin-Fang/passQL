/** 지연 로딩 페이지 청크 대기 화면 (라우트 Suspense fallback) */
export default function PageLoadingFallback() {
  return (
    <div className="flex min-h-[50vh] items-center justify-center" role="status" aria-label="페이지 불러오는 중">
      <span className="loading loading-spinner loading-md text-brand" />
    </div>
  );
}
