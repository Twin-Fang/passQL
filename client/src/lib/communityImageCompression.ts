// 서버 한도와 동일: 원본 WebP 500KB / 긴 변 1600px, 썸네일 WebP 60KB
export const COMMUNITY_IMAGE_MAX_BYTES = 500 * 1024;
export const COMMUNITY_IMAGE_MAX_LONG_SIDE_PIXELS = 1600;
export const COMMUNITY_THUMBNAIL_MAX_BYTES = 60 * 1024;
export const COMMUNITY_THUMBNAIL_MAX_LONG_SIDE_PIXELS = 320;
export const COMMUNITY_POST_MAX_IMAGE_COUNT = 2;

// 화질 단계 (높은 순) > 한도 이하가 될 때까지 낮춤
const WEBP_QUALITY_STEPS: readonly number[] = [0.8, 0.65, 0.5];
// 최저 화질도 한도를 넘으면 크기를 이 비율로 줄여 다시 시도 (최대 횟수 포함)
const DOWNSCALE_RATIO = 0.75;
const MAX_DOWNSCALE_ATTEMPTS = 2;

const WEBP_MIME_TYPE = "image/webp";
const WEBP_HEADER_BYTE_COUNT = 12;

export class CommunityImageCompressionError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "CommunityImageCompressionError";
  }
}

export interface PreparedCommunityImage {
  readonly image: Blob;
  readonly thumbnail: Blob;
}

/** 원본 크기 > 긴 변을 maxLongSidePixels 로 맞춘 크기 (확대 안 함, 최소 1px) */
export function toScaledImageSize(
  width: number,
  height: number,
  maxLongSidePixels: number,
): { readonly width: number; readonly height: number } {
  const scale = Math.min(1, maxLongSidePixels / Math.max(width, height));
  return { width: Math.max(1, Math.round(width * scale)), height: Math.max(1, Math.round(height * scale)) };
}

/** 파일 앞 12바이트가 WebP 헤더(RIFF....WEBP)인지 (서버와 같은 판별) */
export function isWebpHeader(headerBytes: Uint8Array): boolean {
  if (headerBytes.length < WEBP_HEADER_BYTE_COUNT) return false;
  const readAscii = (start: number, end: number) => String.fromCharCode(...headerBytes.slice(start, end));
  return readAscii(0, 4) === "RIFF" && readAscii(8, 12) === "WEBP";
}

async function isWebpBlob(blob: Blob): Promise<boolean> {
  const headerBuffer = await blob.slice(0, WEBP_HEADER_BYTE_COUNT).arrayBuffer();
  return isWebpHeader(new Uint8Array(headerBuffer));
}

function encodeCanvasAsWebp(canvas: HTMLCanvasElement, quality: number): Promise<Blob | null> {
  return new Promise((resolve) => canvas.toBlob(resolve, WEBP_MIME_TYPE, quality));
}

let webpEncodingSupportPromise: Promise<boolean> | null = null;

/** 브라우저가 canvas WebP 인코딩을 지원하는지 (미지원이면 toBlob 이 PNG 로 대체함) */
export function checkWebpEncodingSupport(): Promise<boolean> {
  webpEncodingSupportPromise ??= (async () => {
    try {
      const canvas = document.createElement("canvas");
      canvas.width = 1;
      canvas.height = 1;
      const blob = await encodeCanvasAsWebp(canvas, WEBP_QUALITY_STEPS[0]);
      return blob !== null && blob.type === WEBP_MIME_TYPE && (await isWebpBlob(blob));
    } catch {
      return false;
    }
  })();
  return webpEncodingSupportPromise;
}

interface DecodedImage {
  readonly source: CanvasImageSource;
  readonly width: number;
  readonly height: number;
  readonly release: () => void;
}

// 파일 > 화면 방향이 적용된 이미지 (미지원 형식이면 오류)
async function decodeImageFile(file: File): Promise<DecodedImage> {
  if (typeof createImageBitmap === "function") {
    try {
      const bitmap = await createImageBitmap(file, { imageOrientation: "from-image" });
      return { source: bitmap, width: bitmap.width, height: bitmap.height, release: () => bitmap.close() };
    } catch {
      // Image 요소 경로로 재시도
    }
  }
  const objectUrl = URL.createObjectURL(file);
  try {
    const imageElement = new Image();
    imageElement.src = objectUrl;
    await imageElement.decode();
    return {
      source: imageElement,
      width: imageElement.naturalWidth,
      height: imageElement.naturalHeight,
      release: () => URL.revokeObjectURL(objectUrl),
    };
  } catch {
    URL.revokeObjectURL(objectUrl);
    throw new CommunityImageCompressionError("이 사진은 읽을 수 없어요. 다른 사진을 선택해 주세요");
  }
}

/** 긴 변 제한 > 화질 단계별 WebP 인코딩 > 용량 한도 이하 Blob (canvas 재인코딩이라 EXIF 제거) */
async function compressToWebp(
  decoded: DecodedImage,
  maxLongSidePixels: number,
  maxBytes: number,
): Promise<Blob> {
  let longSidePixels = maxLongSidePixels;
  for (let attempt = 0; attempt <= MAX_DOWNSCALE_ATTEMPTS; attempt += 1) {
    const { width, height } = toScaledImageSize(decoded.width, decoded.height, longSidePixels);
    const canvas = document.createElement("canvas");
    canvas.width = width;
    canvas.height = height;
    canvas.getContext("2d")?.drawImage(decoded.source, 0, 0, width, height);

    for (const quality of WEBP_QUALITY_STEPS) {
      const blob = await encodeCanvasAsWebp(canvas, quality);
      if (blob && blob.size <= maxBytes && blob.type === WEBP_MIME_TYPE && (await isWebpBlob(blob))) return blob;
    }
    longSidePixels = Math.round(longSidePixels * DOWNSCALE_RATIO);
  }
  throw new CommunityImageCompressionError("사진 용량을 줄이지 못했어요. 다른 사진을 선택해 주세요");
}

/** 기기 사진 1장 > 업로드용 원본(≤500KB)·썸네일(≤60KB) WebP */
export async function prepareCommunityImage(file: File): Promise<PreparedCommunityImage> {
  const decoded = await decodeImageFile(file);
  try {
    const image = await compressToWebp(decoded, COMMUNITY_IMAGE_MAX_LONG_SIDE_PIXELS, COMMUNITY_IMAGE_MAX_BYTES);
    const thumbnail = await compressToWebp(decoded, COMMUNITY_THUMBNAIL_MAX_LONG_SIDE_PIXELS, COMMUNITY_THUMBNAIL_MAX_BYTES);
    return { image, thumbnail };
  } finally {
    decoded.release();
  }
}
