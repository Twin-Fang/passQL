import GoogleMobileAds
import UIKit
import google_mobile_ads

/// 네이티브 광고 카드 팩토리: 미디어(120pt 이상 정사각) + 제목·본문·행동 버튼
/// 모양 값은 Dart NativeAdCardStyle.toCustomOptions 가 원본 (키 이름 같이 바꿀 것)
final class PassqlNativeAdFactory: NSObject, FLTNativeAdFactory {
  // Dart GoogleAdNativeLoader.factoryId 와 같게
  static let factoryId = "passqlNativeCard"

  // 제목 <-> 본문 세로 간격 (pt)
  private static let headlineBodyGap: CGFloat = 2

  /// 뷰 생성 > 토큰 값 적용 > 에셋 채움 > 배치 > 광고 연결
  func createNativeAd(
    _ nativeAd: NativeAd,
    customOptions: [AnyHashable: Any]? = nil
  ) -> NativeAdView? {
    let options = CustomOptions(customOptions ?? [:])
    let adView = NativeAdView()
    // 카드 배경 (Flutter 카드 틀과 같은 색 > 경계선 없음)
    adView.backgroundColor = options.color("backgroundColor")

    let mediaView = makeMediaView(options)
    mediaView.mediaContent = nativeAd.mediaContent
    let headlineLabel = makeLabel(
      text: nativeAd.headline,
      color: options.color("headlineColor"),
      font: .systemFont(ofSize: options.number("headlineFontSize"), weight: .semibold),
      lineCount: 2
    )
    let bodyLabel = makeLabel(
      text: nativeAd.body,
      color: options.color("bodyColor"),
      font: .systemFont(ofSize: options.number("bodyFontSize")),
      lineCount: 1
    )
    bodyLabel.isHidden = (nativeAd.body ?? "").isEmpty
    let callToActionButton = makeCallToActionButton(title: nativeAd.callToAction, options: options)

    layout(
      in: adView,
      mediaView: mediaView,
      headlineLabel: headlineLabel,
      bodyLabel: bodyLabel,
      callToActionButton: callToActionButton,
      options: options
    )

    // 클릭·노출 집계 영역 등록 후 광고 연결 (연결이 마지막)
    adView.mediaView = mediaView
    adView.headlineView = headlineLabel
    adView.bodyView = bodyLabel
    adView.callToActionView = callToActionButton
    adView.nativeAd = nativeAd
    return adView
  }

  /// 미디어: 정사각 고정, 잘라내지 않고 맞춤, 모서리 둥글게
  private func makeMediaView(_ options: CustomOptions) -> MediaView {
    let mediaView = MediaView()
    mediaView.contentMode = .scaleAspectFit
    mediaView.backgroundColor = options.color("mediaBackgroundColor")
    mediaView.layer.cornerRadius = options.number("mediaCornerRadius")
    mediaView.clipsToBounds = true
    return mediaView
  }

  private func makeLabel(text: String?, color: UIColor, font: UIFont, lineCount: Int) -> UILabel {
    let label = UILabel()
    label.text = text
    label.textColor = color
    label.font = font
    label.numberOfLines = lineCount
    label.lineBreakMode = .byTruncatingTail
    return label
  }

  /// 행동 버튼: 앱 작은 버튼(tinted·capsule)과 같은 모양. 터치는 SDK 가 처리 (버튼 자체 입력 끔)
  private func makeCallToActionButton(title: String?, options: CustomOptions) -> UIButton {
    let height = options.number("callToActionHeight")
    let horizontalPadding = options.number("callToActionHorizontalPadding")
    var configuration = UIButton.Configuration.plain()
    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 0, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding)
    configuration.titleLineBreakMode = .byTruncatingTail
    let titleFont = UIFont.systemFont(ofSize: options.number("callToActionFontSize"), weight: .semibold)
    configuration.attributedTitle = AttributedString(
      title ?? "",
      attributes: AttributeContainer([
        .font: titleFont,
        .foregroundColor: options.color("callToActionTextColor"),
      ])
    )
    let button = UIButton(configuration: configuration)
    button.backgroundColor = options.color("callToActionBackgroundColor")
    // capsule(999) 등 큰 값은 높이 절반으로 제한
    button.layer.cornerRadius = min(options.number("callToActionCornerRadius"), height / 2)
    button.clipsToBounds = true
    button.isUserInteractionEnabled = false
    button.isHidden = (title ?? "").isEmpty
    return button
  }

  /// 배치: 미디어 왼쪽 > 글자 묶음(제목·본문 위, 버튼 아래) 오른쪽
  private func layout(
    in adView: NativeAdView,
    mediaView: MediaView,
    headlineLabel: UILabel,
    bodyLabel: UILabel,
    callToActionButton: UIButton,
    options: CustomOptions
  ) {
    let textStack = UIStackView(arrangedSubviews: [headlineLabel, bodyLabel])
    textStack.axis = .vertical
    textStack.spacing = Self.headlineBodyGap
    for subview in [mediaView, textStack, callToActionButton] as [UIView] {
      subview.translatesAutoresizingMaskIntoConstraints = false
      adView.addSubview(subview)
    }
    let mediaSize = options.number("mediaSize")
    let contentGap = options.number("contentGap")
    NSLayoutConstraint.activate([
      mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
      mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
      mediaView.widthAnchor.constraint(equalToConstant: mediaSize),
      mediaView.heightAnchor.constraint(equalToConstant: mediaSize),

      textStack.leadingAnchor.constraint(equalTo: mediaView.trailingAnchor, constant: contentGap),
      textStack.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
      textStack.topAnchor.constraint(equalTo: adView.topAnchor),

      callToActionButton.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
      callToActionButton.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor),
      callToActionButton.bottomAnchor.constraint(equalTo: mediaView.bottomAnchor),
      callToActionButton.heightAnchor.constraint(equalToConstant: options.number("callToActionHeight")),
      callToActionButton.topAnchor.constraint(greaterThanOrEqualTo: textStack.bottomAnchor),
    ])
  }
}

/// customOptions 읽기: 숫자(Dart double·int > NSNumber), 색(Dart ARGB 정수 > UIColor). 없으면 0
private struct CustomOptions {
  private let values: [AnyHashable: Any]

  init(_ values: [AnyHashable: Any]) {
    self.values = values
  }

  func number(_ key: String) -> CGFloat {
    CGFloat((values[key] as? NSNumber)?.doubleValue ?? 0)
  }

  func color(_ key: String) -> UIColor {
    let argb = UInt32(truncatingIfNeeded: (values[key] as? NSNumber)?.int64Value ?? 0)
    return UIColor(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255
    )
  }
}
