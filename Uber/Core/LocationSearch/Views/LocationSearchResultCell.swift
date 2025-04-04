import SwiftUI

struct LocationSearchResultCell: View {
    
    let title: String
    let subtitle: String
    
    var body: some View {
        
        HStack {
            
            Image(systemName: "mappin.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
                .accentColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                Divider()
            }// VStack
            .padding(.leading, 8)
            .padding(.vertical, 8)
        }// HStack
        .padding(.leading)
        
    }
}

#Preview {
    LocationSearchResultCell(title: "Starbucks Coffee", subtitle: "123 Main St, Cupertino CA")
}
