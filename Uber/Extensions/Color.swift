import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let backgroundColor = Color("BackgroundColor")
    let secndaryBackgroundColor = Color("SecndaryBackgroundColor")
    let primaryTextColor = Color("PrimaryTextColor")
    let textColor = Color("TextColor")
    let textFieldColor = Color("TextFieldColor")
}
