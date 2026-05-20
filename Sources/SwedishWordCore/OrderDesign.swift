import SwiftUI

enum OrderDesign {
  static let royalBlue = Color(red: 0.0, green: 0.17, blue: 0.39)
  static let midnightBlue = Color(red: 0.0, green: 0.08, blue: 0.22)
  static let swedishBlue = Color(red: 0.0, green: 0.42, blue: 0.65)
  static let goldenYellow = Color(red: 0.99, green: 0.80, blue: 0.0)
  static let antiqueGold = Color(red: 0.78, green: 0.56, blue: 0.13)
  static let cornerRadius: CGFloat = 8

  static var subtleAccent: LinearGradient {
    LinearGradient(
      colors: [
        royalBlue.opacity(0.16),
        goldenYellow.opacity(0.10),
        Color.clear
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  static var widgetBackground: LinearGradient {
    LinearGradient(
      colors: [
        royalBlue,
        swedishBlue.opacity(0.92),
        goldenYellow.opacity(0.82)
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  static var goldRule: some View {
    Rectangle()
      .fill(goldenYellow)
      .frame(width: 56, height: 3)
      .clipShape(Capsule())
  }
}

struct OrderAppBackground: View {
  var body: some View {
    #if os(iOS)
    ZStack {
      LinearGradient(
        colors: [
          OrderDesign.midnightBlue,
          OrderDesign.royalBlue,
          OrderDesign.swedishBlue.opacity(0.88)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      RadialGradient(
        colors: [
          OrderDesign.goldenYellow.opacity(0.24),
          .clear
        ],
        center: .topTrailing,
        startRadius: 20,
        endRadius: 420
      )
      RadialGradient(
        colors: [
          .white.opacity(0.10),
          .clear
        ],
        center: .bottomLeading,
        startRadius: 10,
        endRadius: 360
      )
    }
    .ignoresSafeArea()
    #else
    ZStack {
      platformBackground
      OrderDesign.subtleAccent
        .ignoresSafeArea()
    }
    #endif
  }

  private var platformBackground: Color {
    #if os(iOS)
    Color(uiColor: .systemGroupedBackground)
    #elseif os(macOS)
    Color(nsColor: .windowBackgroundColor)
    #else
    Color(.systemBackground)
    #endif
  }
}

struct OrderSurfaceModifier: ViewModifier {
  var tint: Color = OrderDesign.royalBlue.opacity(0.10)

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: OrderDesign.cornerRadius, style: .continuous)
          .fill(.regularMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: OrderDesign.cornerRadius, style: .continuous)
              .stroke(tint, lineWidth: 1)
          )
      )
  }
}

extension View {
  func orderSurface(tint: Color = OrderDesign.royalBlue.opacity(0.10)) -> some View {
    modifier(OrderSurfaceModifier(tint: tint))
  }
}
