import GoogleMobileAds
import UIKit
import google_mobile_ads

/// 탭 바 아래 한 줄 광고 띠 팩토리 (#527): 뷰 구성 > 색 적용 > 에셋 그대로 연결
/// 띠 전체가 NativeAdView (클릭 영역이 광고 뷰 밖으로 나가지 않음). 에셋 문구 가공 없음, AdChoices 는 SDK 기본 위치
final class PassqlStripNativeAdFactory: NSObject, FLTNativeAdFactory {
  // Flutter GoogleAdNativeStripLoader.factoryId 와 같은 값
  static let factoryId = "passqlStrip"

  // customOptions 키: Flutter GoogleAdNativeStripLoader 와 같은 값
  private enum OptionKey {
    static let backgroundColor = "backgroundColor"
    static let headlineColor = "headlineColor"
    static let callToActionColor = "callToActionColor"
    static let badgeBackgroundColor = "badgeBackgroundColor"
    static let badgeTextColor = "badgeTextColor"
    static let badgeLabel = "badgeLabel"
  }

  // 배치 수치 (Android passql_strip_native_ad.xml 과 같은 값)
  private enum Layout {
    static let leadingInset: CGFloat = 16
    // 오른쪽 끝 여백: SDK 가 위 오른쪽 모서리에 두는 AdChoices 아이콘을 화살표가 가리지 않게
    static let trailingInset: CGFloat = 24
    static let itemSpacing: CGFloat = 8
    static let chevronSpacing: CGFloat = 2
    static let badgeHorizontalPadding: CGFloat = 6
    static let badgeVerticalPadding: CGFloat = 2
    static let badgeFontSize: CGFloat = 11
    static let headlineFontSize: CGFloat = 14
    static let callToActionFontSize: CGFloat = 13
    static let chevronSize: CGFloat = 12
  }

  // 옵션 누락 시 기본값 (Flutter 가 항상 넘기므로 방어용)
  private static let fallbackBadgeLabel = "AD"

  func createNativeAd(
    _ nativeAd: NativeAd,
    customOptions: [AnyHashable: Any]? = nil
  ) -> NativeAdView? {
    let adView = NativeAdView()
    let callToActionColor = Self.color(customOptions, OptionKey.callToActionColor) ?? .label
    adView.backgroundColor = Self.color(customOptions, OptionKey.backgroundColor) ?? .systemBackground

    // 배지 (광고 표시, 정책상 필수)
    let badgeLabel = PassqlStripBadgeLabel(
      horizontalPadding: Layout.badgeHorizontalPadding,
      verticalPadding: Layout.badgeVerticalPadding
    )
    badgeLabel.text = customOptions?[OptionKey.badgeLabel] as? String ?? Self.fallbackBadgeLabel
    badgeLabel.font = .systemFont(ofSize: Layout.badgeFontSize, weight: .bold)
    badgeLabel.textColor = Self.color(customOptions, OptionKey.badgeTextColor) ?? .secondaryLabel
    badgeLabel.backgroundColor = Self.color(customOptions, OptionKey.badgeBackgroundColor) ?? .systemFill
    badgeLabel.clipsToBounds = true
    badgeLabel.setContentHuggingPriority(.required, for: .horizontal)
    badgeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

    // 헤드라인 (필수, 1줄 말줄임)
    let headlineLabel = UILabel()
    headlineLabel.text = nativeAd.headline
    headlineLabel.font = .systemFont(ofSize: Layout.headlineFontSize)
    headlineLabel.textColor = Self.color(customOptions, OptionKey.headlineColor) ?? .label
    headlineLabel.numberOfLines = 1
    headlineLabel.lineBreakMode = .byTruncatingTail
    headlineLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    // 남는 폭은 헤드라인이 차지 > 행동 문구·화살표는 오른쪽 끝 (Android layout_weight=1 과 같은 배치)
    headlineLabel.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
    adView.headlineView = headlineLabel

    // 행동 문구 (있을 때만, 없으면 화살표만, 클릭은 헤드라인). 터치는 광고 뷰가 받음
    let callToActionLabel = UILabel()
    callToActionLabel.font = .systemFont(ofSize: Layout.callToActionFontSize, weight: .bold)
    callToActionLabel.textColor = callToActionColor
    callToActionLabel.isUserInteractionEnabled = false
    callToActionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    // 스택 뷰는 고유 크기가 없어 묶음 대신 안쪽 라벨이 글자 폭에 붙어 있게
    callToActionLabel.setContentHuggingPriority(.required, for: .horizontal)
    if let callToAction = nativeAd.callToAction, !callToAction.isEmpty {
      callToActionLabel.text = callToAction
    } else {
      callToActionLabel.isHidden = true
    }

    let chevronView = UIImageView(
      image: UIImage(
        systemName: "chevron.right",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: Layout.chevronSize, weight: .semibold)
      )
    )
    chevronView.tintColor = callToActionColor
    chevronView.setContentHuggingPriority(.required, for: .horizontal)
    chevronView.isAccessibilityElement = false

    // 행동 문구 + 화살표 묶음 = 광고 callToActionView (화살표를 눌러도 광고 클릭)
    let callToActionGroup = UIStackView(arrangedSubviews: [callToActionLabel, chevronView])
    callToActionGroup.axis = .horizontal
    callToActionGroup.alignment = .center
    callToActionGroup.spacing = Layout.chevronSpacing
    callToActionGroup.isUserInteractionEnabled = false
    if !callToActionLabel.isHidden {
      adView.callToActionView = callToActionGroup
    }

    // 배치: 배지 > 헤드라인 > 행동 문구 > 화살표 (가로 한 줄, 세로 가운데)
    let rowStack = UIStackView(arrangedSubviews: [badgeLabel, headlineLabel, callToActionGroup])
    rowStack.axis = .horizontal
    rowStack.alignment = .center
    rowStack.spacing = Layout.itemSpacing
    rowStack.translatesAutoresizingMaskIntoConstraints = false
    adView.addSubview(rowStack)
    NSLayoutConstraint.activate([
      rowStack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: Layout.leadingInset),
      rowStack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -Layout.trailingInset),
      rowStack.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
    ])

    adView.nativeAd = nativeAd
    return adView
  }

  // Flutter ARGB 정수 > UIColor (없으면 nil)
  private static func color(_ options: [AnyHashable: Any]?, _ key: String) -> UIColor? {
    guard let number = options?[key] as? NSNumber else { return nil }
    let argb = number.uint32Value
    return UIColor(
      red: CGFloat((argb >> 16) & 0xFF) / 255,
      green: CGFloat((argb >> 8) & 0xFF) / 255,
      blue: CGFloat(argb & 0xFF) / 255,
      alpha: CGFloat((argb >> 24) & 0xFF) / 255
    )
  }
}

/// 안쪽 여백이 있는 캡슐 배지 라벨 (높이 절반 반경)
private final class PassqlStripBadgeLabel: UILabel {
  private let contentInsets: UIEdgeInsets

  init(horizontalPadding: CGFloat, verticalPadding: CGFloat) {
    contentInsets = UIEdgeInsets(
      top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    super.init(frame: .zero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported")
  }

  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: contentInsets))
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + contentInsets.left + contentInsets.right,
      height: size.height + contentInsets.top + contentInsets.bottom)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
  }
}
