import { useState } from "react";

interface ProfileAvatarProps {
  /** 첫 글자 원에 쓰는 이름 (비면 ?) */
  readonly fallbackName: string;
  readonly imageUrl?: string | null;
}

/**
 * 프로필 사진 (#908): 소셜 이미지 원형 자르기 > 없음·실패면 이름 첫 글자 원
 * 장식 요소라 스크린리더에서 숨김 (옆 닉네임이 읽힘), referrer 미전송 (제공자 CDN 이 외부 referrer 거절)
 */
export default function ProfileAvatar({ fallbackName, imageUrl }: ProfileAvatarProps) {
  // 실패한 주소 기록 (주소가 바뀌면 다시 시도)
  const [failedImageUrl, setFailedImageUrl] = useState<string | null>(null);
  const isImageUsable = !!imageUrl && imageUrl !== failedImageUrl;
  const initial = (Array.from(fallbackName.trim())[0] ?? "?").toUpperCase();
  return (
    <div className="w-14 h-14 rounded-full bg-brand flex items-center justify-center shrink-0 overflow-hidden" aria-hidden="true">
      {isImageUsable ? (
        <img
          src={imageUrl}
          alt=""
          width={56}
          height={56}
          loading="lazy"
          decoding="async"
          referrerPolicy="no-referrer"
          className="w-full h-full object-cover"
          onError={() => setFailedImageUrl(imageUrl)}
        />
      ) : (
        <span className="text-2xl font-bold text-on-brand">{initial}</span>
      )}
    </div>
  );
}
