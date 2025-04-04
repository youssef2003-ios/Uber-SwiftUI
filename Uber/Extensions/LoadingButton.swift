import SwiftUI

struct LoadingButton: View {
    let text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.blue)
                .opacity(0.5)
                .frame(height: 50)
            
            HStack {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.3)
                    .padding(.trailing, 8)
                
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LoadingButton(text: "LOADING...")
        .background(Color.black)
}
