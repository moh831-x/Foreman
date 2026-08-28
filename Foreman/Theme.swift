import SwiftUI

extension Color {
    static let foremanInk = Color(red: 0x1F/255, green: 0x2A/255, blue: 0x24/255)
    static let foremanInk2 = Color(red: 0x28/255, green: 0x3A/255, blue: 0x31/255)
    static let foremanPaper = Color(red: 0xED/255, green: 0xE7/255, blue: 0xD3/255)
    static let foremanPaperDim = Color(red: 0xDE/255, green: 0xD6/255, blue: 0xBC/255)
    static let foremanAmber = Color(red: 0xE8/255, green: 0xB9/255, blue: 0x3F/255)
    static let foremanBrick = Color(red: 0xB3/255, green: 0x3F/255, blue: 0x2D/255)
    static let foremanSteel = Color(red: 0x5B/255, green: 0x6B/255, blue: 0x62/255)
}

struct ForemanButtonStyle: ButtonStyle {
    enum Kind { case primary, ghost, danger }
    var kind: Kind = .primary

    func makeBody(configuration: Configuration) -> some View {
        let bg: Color = {
            switch kind {
            case .primary: return .foremanAmber
            case .danger: return .foremanBrick
            case .ghost: return .clear
            }
        }()
        let fg: Color = kind == .ghost ? .foremanPaper : .foremanInk == .foremanInk && kind == .danger ? .foremanPaper : .foremanInk

        configuration.label
            .font(.system(size: 13, weight: .bold))
            .textCase(.uppercase)
            .tracking(0.6)
            .padding(.vertical, 10)
            .padding(.horizontal, 18)
            .foregroundColor(kind == .primary ? .foremanInk : .foremanPaper)
            .background(bg)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(kind == .ghost ? Color.foremanPaper : Color.foremanInk, lineWidth: 2)
            )
            .cornerRadius(3)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.15 : 0.35), radius: 0,
                    x: configuration.isPressed ? 1 : 3, y: configuration.isPressed ? 1 : 3)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .foregroundColor(fg)
    }
}

/// Faint dot-grid backdrop, echoes the pegboard texture from the web version.
struct PegboardBackground: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 22
            var x: CGFloat = 0
            while x < size.width {
                var y: CGFloat = 0
                while y < size.height {
                    let rect = CGRect(x: x, y: y, width: 1.6, height: 1.6)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.foremanPaper.opacity(0.07)))
                    y += spacing
                }
                x += spacing
            }
        }
    }
}
