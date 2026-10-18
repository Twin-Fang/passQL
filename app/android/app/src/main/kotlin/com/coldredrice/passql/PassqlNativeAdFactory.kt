package com.coldredrice.passql

import android.content.Context
import android.graphics.Outline
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewOutlineProvider
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import com.google.android.gms.ads.nativead.MediaView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.NativeAdFactory

/**
 * 네이티브 광고 카드 팩토리: 미디어(120dp 이상 정사각) + 제목·본문·행동 버튼
 * 모양 값은 Dart NativeAdCardStyle.toCustomOptions 가 원본 (키 이름 같이 바꿀 것)
 */
class PassqlNativeAdFactory(private val context: Context) : NativeAdFactory {
    companion object {
        // Dart GoogleAdNativeLoader.factoryId 와 같게
        const val FACTORY_ID = "passqlNativeCard"

        // 제목 <-> 본문 세로 간격 (dp)
        private const val HEADLINE_BODY_GAP_DP = 2f
    }

    /** 레이아웃 생성 > 토큰 값 적용 > 에셋 채움 > 광고 연결 */
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val options = customOptions ?: emptyMap()
        val adView = LayoutInflater.from(context)
            .inflate(R.layout.passql_native_ad_card, null) as NativeAdView
        val mediaView = adView.findViewById<MediaView>(R.id.ad_media)
        val textColumn = adView.findViewById<LinearLayout>(R.id.ad_text_column)
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val callToActionView = adView.findViewById<TextView>(R.id.ad_call_to_action)

        // 카드 배경 (Flutter 카드 틀과 같은 색 > 경계선 없음)
        adView.setBackgroundColor(options.colorOf("backgroundColor"))

        // 미디어: 정사각 고정, 잘라내지 않고 맞춤, 모서리 둥글게
        val mediaSizePixels = dpToPixels(options.numberOf("mediaSize"))
        mediaView.layoutParams = LinearLayout.LayoutParams(mediaSizePixels, mediaSizePixels)
        mediaView.setImageScaleType(ImageView.ScaleType.FIT_CENTER)
        mediaView.setBackgroundColor(options.colorOf("mediaBackgroundColor"))
        clipToRoundedRect(mediaView, dpToPixels(options.numberOf("mediaCornerRadius")).toFloat())
        mediaView.mediaContent = nativeAd.mediaContent

        // 글자 묶음: 미디어와 간격
        (textColumn.layoutParams as LinearLayout.LayoutParams).marginStart =
            dpToPixels(options.numberOf("contentGap"))

        // 제목·본문 (본문 없으면 자리 없음)
        headlineView.text = nativeAd.headline
        headlineView.setTextColor(options.colorOf("headlineColor"))
        headlineView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, options.numberOf("headlineFontSize").toFloat())
        bodyView.text = nativeAd.body
        bodyView.setTextColor(options.colorOf("bodyColor"))
        bodyView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, options.numberOf("bodyFontSize").toFloat())
        bodyView.setPadding(0, dpToPixels(HEADLINE_BODY_GAP_DP.toDouble()), 0, 0)
        bodyView.visibility = if (nativeAd.body.isNullOrBlank()) View.GONE else View.VISIBLE

        // 행동 버튼: 앱 작은 버튼(tinted·capsule)과 같은 모양 (없으면 숨김)
        styleCallToAction(callToActionView, options)
        callToActionView.text = nativeAd.callToAction
        callToActionView.visibility =
            if (nativeAd.callToAction.isNullOrBlank()) View.INVISIBLE else View.VISIBLE

        // 클릭·노출 집계 영역 등록 후 광고 연결 (연결이 마지막)
        adView.mediaView = mediaView
        adView.headlineView = headlineView
        adView.bodyView = bodyView
        adView.callToActionView = callToActionView
        adView.setNativeAd(nativeAd)
        return adView
    }

    private fun styleCallToAction(view: TextView, options: Map<String, Any>) {
        val horizontalPaddingPixels = dpToPixels(options.numberOf("callToActionHorizontalPadding"))
        view.height = dpToPixels(options.numberOf("callToActionHeight"))
        view.setPadding(horizontalPaddingPixels, 0, horizontalPaddingPixels, 0)
        view.setTextColor(options.colorOf("callToActionTextColor"))
        view.setTextSize(TypedValue.COMPLEX_UNIT_DIP, options.numberOf("callToActionFontSize").toFloat())
        view.background = GradientDrawable().apply {
            setColor(options.colorOf("callToActionBackgroundColor"))
            // capsule(999) 등 큰 값도 높이 절반으로 그려짐
            cornerRadius = dpToPixels(options.numberOf("callToActionCornerRadius")).toFloat()
        }
    }

    private fun clipToRoundedRect(view: View, radiusPixels: Float) {
        view.outlineProvider = object : ViewOutlineProvider() {
            override fun getOutline(target: View, outline: Outline) {
                outline.setRoundRect(0, 0, target.width, target.height, radiusPixels)
            }
        }
        view.clipToOutline = true
    }

    private fun dpToPixels(dp: Double): Int =
        (dp * context.resources.displayMetrics.density).toInt()

    // customOptions 숫자 (Dart double·int 모두 Number). 없으면 0
    private fun Map<String, Any>.numberOf(key: String): Double =
        (this[key] as? Number)?.toDouble() ?: 0.0

    // customOptions 색 (Dart ARGB 정수, 32비트 넘으면 Long) > Android 색 정수
    private fun Map<String, Any>.colorOf(key: String): Int =
        (this[key] as? Number)?.toLong()?.toInt() ?: 0
}
