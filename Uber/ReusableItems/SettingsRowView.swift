import SwiftUI

struct SettingsRowView: View {
    
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.medium)
                .font(.title)
                .foregroundColor(tintColor)
           
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(Color.theme.primaryTextColor)
        }// HStack1
        .padding(4)
        
    }
}

#Preview {
    SettingsRowView(imageName: "house.circle.fill", title: "Home", tintColor: .blue)
}
